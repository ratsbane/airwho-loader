
## Install Postfix on the server

    sudo apt install postfix


## Configure SPF and DKIM and add to host file at registrar

See https://support.google.com/a/answer/33786

    airwho.com.		3600	IN	TXT	"v=spf1 ip4:96.71.136.46 include:_spf.google.com ~all"


## Configure DKIM

See https://www.linuxbabe.com/mail-server/setting-up-dkim-and-spf (with some adjustments)

OpenDKIM configuration file settings: http://opendkim.org/opendkim.conf.5.html

Install opendkim

    sudo apt install opendkim opendkim-tools

Add the postfix user to the opendkim group

    sudo gpasswd -a postfix opendkim

Edit /etc/opendkim.conf

Uncomment these lines and change the Canonicalization value from "simple" to "relaxed/simple"

    Canonicalization        relaxed/simple
    Mode                    sv
    SubDomains              no

Add these lines.  I put them after "SubDomains no" as the LinuxBabe.com post suggested, but they could go anywhere.

    AutoRestart         yes
    AutoRestartRate     10/1M
    Background          yes
    DNSTimeout          5
    SignatureAlgorithm  rsa-sha256

Add these lines.  I put them at the end of the file as Linuxbabe.com suggested:

    # Map domains in From addresses to keys used to sign messages
    KeyTable           /etc/opendkim/key.table
    SigningTable       refile:/etc/opendkim/signing.table

    # Hosts to ignore when verifying signatures
    ExternalIgnoreList  /etc/opendkim/trusted.hosts
    InternalHosts       /etc/opendkim/trusted.hosts

Create a directory to hold the opendkim configuration and keys:

    doug@airwho:/etc/opendkim$ sudo mkdir /etc/opendkim
    doug@airwho:/etc/opendkim$ sudo mkdir /etc/opendkim/keys

Set appropriate permissions on those files:
    doug@airwho:/etc/opendkim$ sudo chown -R opendkim:opendkim /etc/opendkim
    doug@airwho:/etc/opendkim$ sudo chmod go-rw /etc/opendkim/keys

Create the signing table:
    doug@airwho:/etc/opendkim$ sudo vim /etc/opendkim/signing.table

Put the following text in that file.  Note that the word "default" is the selector we will use later.  It can be anything, as long as it's consistent:
    *@airwho.com default._domainkey.airwho

Create the key table file:
    doug@airwho:/etc/opendkim$ sudo vim /etc/opendkim/key.table

Put the following text in that file:
    default._domainkey.airwho    airwho.com:default:/etc/opendkim/keys/airwho.com/default.private

Create the trusted hosts file:
    sudo mkdir /etc/opendkim/trusted.hosts

Put the following text in that file:
    127.0.0.1
    localhost
    
    *.airwho.com

Create a subdirectory under "key" for airwho:
    doug@airwho:/etc/opendkim$ sudo mkdir /etc/opendkim/keys/airwho.com


Generate a key pair.  This creates two files in your current directory, "mail.private" and "mail.txt"  You will move the private key to a secure place, /etc/dkimkeys, and paste the contents of the public one, mail.txt into a DNS host record.

    doug@airwho:/etc/opendkim$ sudo opendkim-genkey -b 2048 -d airwho.com -D /etc/opendkim/keys/airwho.com -s default -v
    opendkim-genkey: generating private key
    opendkim-genkey: private key written to default.private
    opendkim-genkey: extracting public key
    opendkim-genkey: DNS TXT record written to default.txt

Set file owner of the private key:
    doug@airwho:/etc/opendkim$ sudo chown opendkim:opendkim /etc/opendkim/keys/airwho.com/default.private

Create two host records, a policy record with the host \_domainkey and the other one with the host including your selector.  I'm using "default" as the selector.

### Policy DKIM record
    \_domainkey.airwho.com.	3600	IN	TXT	"o=-"

The dash means all emails from this domain _must_ be signed with the DKIM key.  (A tilde means _should_ be signed)


### Selector DKIM record

    doug@airwho:/etc/opendkim$ sudo cat keys/airwho.com/default.txt

Create a host record that looks like the one below.  Note that the "p=" field contains the text from the mail.txt file that opendkim-genkey created above.
 
    v=DKIM1; h=sha256; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwJa2mTHbbSBcfYhC2rey7GqEr6F9AMa3p+Uq9EHH5x+8fLvCpZp8oL38SWxK3j7cY30az8LkyF35ijBGIbcdyPmJSkuDZ3+3G4kllc7yvR0GM/xbgl9ELGOT1OO3REh1qtF66w++GJbMxRnm96BIV2wmjA/BIo0W0rn+RUsNZ8x7Mo9hUC1Jw1lW3XRCzHowQ0dzZ3AM4Vr9xB4ddDuImi6FI8zPQxB3JAfXihrmU/TkNtAhUBpnz5z4pK5xVk8Em0keXhI/i9OiQU3BiZFx89NYzMXG7iQ5ZLWIE3SRAXK/oa0ZvqzBAqFz2addZpuEu8/R8FAReCEKEYvkr3dIyQIDAQAB

Confirm that host record:

    dig -t txt default._domainkey.airwho.com

Test.  Note that the "key not secure" message is probably because the private key file is owned by opendkim user and not root, who we are testing as (TODO: is this correct?):
    doug@airwho:/etc/opendkim$ sudo opendkim-testkey -d airwho.com -s default -vvv
    opendkim-testkey: using default configfile /etc/opendkim.conf
    opendkim-testkey: checking key 'default._domainkey.airwho.com'
    opendkim-testkey: key not secure
    opendkim-testkey: key OK 


### Configure Postfix to use DKIM

Note that this is probably the most confusing part of the process so far.  There are several, if not an infinite number of ways of configuring the way that Postfix talks to OpenDKIM.  I experimented with several before settling on something very close to that described in the linuxbabe.com article:

    doug@airwho:/etc/opendkim$ sudo vim /etc/opendkim.conf 

And replace the existing Socket line with:

    Socket                  local:/var/spool/postfix/opendkim/opendkim.sock


Tell Postfix to use OpenDKIM:

    doug@airwho:/etc/opendkim$ sudo vim /etc/postfix/main.cf

Add the following lines anywhere:
    # Milter configuration
    milter_default_action = accept
    milter_protocol = 6
    smtpd_milters = local:/opendkim/opendkim.sock
    non_smtpd_milters = $smtpd_milters

Restart DKIM and Postfix:

    doug@airwho:/etc/opendkim$ sudo service opendkim restart
    doug@airwho:/etc/opendkim$ sudo service postfix restart

DKIM tester: http://www.appmaildev.com/en/domainkey




## Configure DMARC

Put the following record in the hosts file:

    _dmarc.airwho.com.	3600	IN	TXT	"v=DMARC1; p=none; rua=mailto:dmarc_rua@airwho.com; ruf=mailto:dmarc_ruf@airwho.com;"


## Verify SPF, DKIM, and DMARC

See https://toolbox.googleapps.com/apps/checkmx/check?domain=airwho.com&dkim_selector=mail

Also see http://www.appmaildev.com/en/dkim/




## Configure TLS encryption

See https://support.google.com/mail/answer/6330403
See http://www.postfix.org/TLS_README.html

    sudo mkdir /etc/ssl/private/airwho

Rsync keys from webserver into that directory.  NOTE! When certbot renews those, we will have to recopy them.

    sudo vim /etc/postfix/main.cf

Edit the lines

    smtpd_tls_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem  
    smtpd_tls_key_file=/etc/ssl/private/ssl-cert-snakeoil.key

to be

    smtpd_tls_cert_file=/etc/ssl/private/airwho/fullchain.pem  
    smtpd_tls_key_file=/etc/ssl/private/airwho/privkey.pem

and add the following lines:

    smtp_use_tls=yes  
    smtp_tls_loglevel = 1  
    smtp_tls_security_level = may  
    smtp_tls_cert_file=/etc/ssl/private/airwho/fullchain.pem  
    smtp_tls_key_file=/etc/ssl/private/airwho/privkey.pem

    service postfix restart

(While restarting Postfix it's useful to tail the mail.log in another terminal)  
    sudo tail -f /var/log/mail.log




