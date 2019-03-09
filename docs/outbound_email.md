
## Install Postfix on the server

`sudo apt install postfix`


## Configure SPF and DKIM and add to host file at registrar

See https://support.google.com/a/answer/33786

`airwho.com.		3600	IN	TXT	"v=spf1 ip4:96.71.136.46 include:_spf.google.com ~all"`


## Configure DKIM

`sudo apt install opendkim opendkim-tools`

`sudo vim /etc/opendkim.conf` 

`opendkim-genkey -t -s mail -d airwho.com`

`sudo cp mail.private /etc/mail/dkim.key`

Create two host records, a policy record with the host \_domainkey and the other one with the host including your selector.  I'm using "mail" as the selector because that was the default with opendkim: mail.\_domainkey

### Policy DKIM record
`\_domainkey.airwho.com.	3600	IN	TXT	"o=-"`

The dash means all emails from this domain _must_ be signed with the DKIM key.  (A tilde means _should_ be signed)


### Selector DKIM record
Create a host record that looks like the one below.  Note that the "p=" field contains the text from the mail.txt file that opendkim-genkey created above.

`dig -t txt default._domainkey.airwho.com`

`default._domainkey.airwho.com. 3600 IN	TXT	"v=DKIM1; h=sha256; k=rsa; t=y; p= MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAs4tLFX82rV4nn25LA8Z/29AeKIbaScnaDw8sIh1s0DfpQfxN/p/xlRMGagV9eg3SSdOVwwksTK/vYWmpUykrVgjWb930tAqZpBIuCGfBDtBkEue7ChDjlQVBCiTK0tqcWEFgHq6PBQtT7Pd8BS4YweiJHFjKWH7yvOCuTfxZL0ktE/GhH" "XFrBgZyWmO26PnWbvqKMHn5xAmPGZ0gXxlrUVATdb4LcGc1JsPPjtAnsSQvIPvjeGNnOGSpXOk5GV2++Tz2A7KPYdqCD1IrPap96RW6dH5efknChhyV812ZPy5U5cJSsLg/QPGgoK56o9oxCmCu32ZGyB5U4rlszg4cVQIDAQAB"`

DKIM tester: http://www.appmaildev.com/en/domainkey


## Configure DMARC

`_dmarc.airwho.com.	3600	IN	TXT	"v=DMARC1; p=none; rua=mailto:dmarc_rua@airwho.com; ruf=mailto:dmarc_ruf@airwho.com;"`


## Verify SPF, DKIM, and DMARC

See https://toolbox.googleapps.com/apps/checkmx/check?domain=airwho.com&dkim_selector=mail


## Configure TLS encryption

See https://support.google.com/mail/answer/6330403
See http://www.postfix.org/TLS_README.html

`sudo mkdir /etc/ssl/private/airwho`

Rsync keys from webserver into that directory.  NOTE! When certbot renews those, we will have to recopy them.

`sudo vim /etc/postfix/main.cf`

Edit the lines

`    smtpd_tls_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem  
     smtpd_tls_key_file=/etc/ssl/private/ssl-cert-snakeoil.key`

to be

`    smtpd_tls_cert_file=/etc/ssl/private/airwho/fullchain.pem  
     smtpd_tls_key_file=/etc/ssl/private/airwho/privkey.pem`

and add the following lines:

`    smtp_use_tls=yes  
     smtp_tls_loglevel = 1  
     smtp_tls_security_level = may  
     smtp_tls_cert_file=/etc/ssl/private/airwho/fullchain.pem  
     smtp_tls_key_file=/etc/ssl/private/airwho/privkey.pem`

    `service postfix restart`

(While restarting Postfix it's useful to tail the mail.log in another terminal)  
    `sudo tail -f /var/log/mail.log`

