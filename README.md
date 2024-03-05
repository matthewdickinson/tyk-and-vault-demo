# What

Tyk documentation [states](https://tyk.io/docs/tyk-configuration-reference/kv-store/#usage-information) 
> The KV system can be used in the following places:
>
> 1.   Configuration file - tyk.conf
> 2.   Environment variables - .env which supersedes the configuration file.
> 3.   API Definition - currently, only the listen path and target URL
> 4.   Body transforms and URL rewrites

However, the `security.certificates.upstream` cert definition doesn't seem to actually support this.

# How
You can see this by booting this sample application:
```bash
docker compose up
```
Note: You might need to stop the containers and restart if Docker decides to boot Tyk before the `vault_preloader` finishes.

You can see that this now responds to requests:
```bash
curl http://localhost:8080/test/ # Reads target_url from Vault secret

curl http://localhost:8080/test2/ # Reads target_url from env secret
curl http://localhost:8080/test2/1 # Reads target_url from env secret
```

However, you will notice when hitting `test` that Tyk kicks out this log: 
```
tyk-1            | time="Mar 05 21:09:09" level=warning msg="Can't retrieve certificate:vault://secret/tyk.combinedopen vault://secret/tyk.combined: no such file or directory" prefix=cert_storage
```

You can switch the `*.env` and `*` settings in `security.certificates.upstream` to try to read this from `env://` (as works for `target_url`) and you will see a matching error:
```
tyk-1            | time="Mar 05 21:13:05" level=warning msg="Can't retrieve certificate:env://test_client_certopen env://test_client_cert: no such file or directory" prefix=cert_storage
```

However, switching `*.file` and `*` will correctly send load the certificate.


# Why
I'd like to be able to load my upstream certificates from an encrypted source like Vault instead of hard-coding them.
However, the way that Tyk works right now, it seems that you can only do this via hard-coded certs or using a cert ID
and adding a intermediate layer to post keys to `/tyk/keys`.