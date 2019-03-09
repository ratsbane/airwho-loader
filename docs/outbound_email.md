
## Install Postfix on the server

`sudo apt install postfix`


## Configure SPF and DKIM and add to host file at registrar

See https://support.google.com/a/answer/33786


`sudo apt install opendkim opendkim-tools`

`sudo vim /etc/opendkim.conf` 

`opendkim-genkey -t -s mail -d airwho.com`

`sudo cp mail.private /etc/mail/dkim.key`



`airwho.com.		3600	IN	TXT	"v=spf1 ip4:96.71.136.46 include:_spf.google.com ~all"
airwho.com.		3600	IN	TXT	"v=DMARC1; p=none; rua=mailto:admin@airwho.com; ruf=mailto:admin.dmarc@airwho.com;"
airwho.com.		3600	IN	TXT	"v=DKIM1; h=sha256; k=rsa; t=y; p= MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAs4tLFX82rV4nn25LA8Z/29AeKIbaScnaDw8sIh1s0DfpQfxN/p/xlRMGagV9eg3SSdOVwwksTK/vYWmpUykrVgjWb930tAqZpBIuCGfBDtBkEue7ChDjlQVBCiTK0tqcWEFgHq6PBQtT7Pd8BS4YweiJHFjKWH7yvOCuTfxZL0ktE/GhH" "XFrBgZyWmO26PnWbvqKMHn5xAmPGZ0gXxlrUVATdb4LcGc1JsPPjtAnsSQvIPvjeGNnOGSpXOk5GV2++Tz2A7KPYdqCD1IrPap96RW6dH5efknChhyV812ZPy5U5cJSsLg/QPGgoK56o9oxCmCu32ZGyB5U4rlszg4cVQIDAQAB"
`

Note that something's wrong with the DKIM and DMARC records.  See https://toolbox.googleapps.com/apps/checkmx/check?domain=airwho.com&dkim_selector=


## Configure TLS encryption

See https://support.google.com/mail/answer/6330403

`sudo mkdir /etc/ssl/private/airwho`

Rsync keys from webserver into that directory.  NOTE! When certbot renews those, we will have to recopy them.



