# CloudFlare Connection libraries for Laravel from 10.x

<p align="center">
<a href="https://packagist.org/packages/diepxuan/laravel-cloudflare"><img src="https://img.shields.io/packagist/dt/diepxuan/laravel-cloudflare.svg?style=flat-square" alt="Total Downloads"></a>
<a href="https://packagist.org/packages/diepxuan/laravel-cloudflare"><img src="https://img.shields.io/packagist/v/diepxuan/laravel-cloudflare.svg?style=flat-square" alt="Latest Stable Version"></a>
<a href="https://packagist.org/packages/diepxuan/laravel-cloudflare"><img src="https://img.shields.io/packagist/l/diepxuan/laravel-cloudflare.svg?style=flat-square" alt="License"></a>
</p>

## Cloudflare API version 4

Follow Cloudflare SDK (v4 API Binding for PHP 7)
This repository is currently under development, additional classes and endpoints being actively added.

## Getting Started

```php
$key     = new Cloudflare\API\Auth\APIKey('user@example.com', 'apiKey');
$adapter = new Cloudflare\API\Adapter\Guzzle($key);
$user    = new Cloudflare\API\Endpoints\User($adapter);

echo $user->getUserID();
```

## Installation

### Require using composer

```bash
composer require diepxuan/laravel-cloudflare
```

### Base

The recommended way to install this package is via the Packagist Dependency Manager ([cloudflare/sdk](https://packagist.org/packages/cloudflare/sdk)).
You can get specific usage examples on the Cloudflare Knowledge Base under: [Cloudflare PHP API Binding](https://support.cloudflare.com/hc/en-us/articles/115001661191)

In Laravel 5.5, and above, the package will auto-register the service provider. In Laravel 5.4 you must install this service provider.

## About this package

[![Build Status](https://travis-ci.org/cloudflare/cloudflare-php.svg?branch=master)](https://travis-ci.org/cloudflare/cloudflare-php)
[Cloudflare SDK (v4 API Binding for PHP 7)](https://github.com/cloudflare/cloudflare-php)

## Cloudflare API version 4

The Cloudflare API can be found [here](https://api.cloudflare.com/).
Each API call is provided via a similarly named function within various classes in the **Cloudflare\API\Endpoints** namespace:

-   [x] [DNS Records](https://www.cloudflare.com/dns/)
-   [x] [DNS Analytics](https://api.cloudflare.com/#dns-analytics-table)
-   [x] Zones
-   [x] User Administration (partial)
-   [x] [Cloudflare IPs](https://www.cloudflare.com/ips/)
-   [x] [Page Rules](https://support.cloudflare.com/hc/en-us/articles/200168306-Is-there-a-tutorial-for-Page-Rules-)
-   [x] [Web Application Firewall (WAF)](https://www.cloudflare.com/waf/)
-   [ ] Virtual DNS Management
-   [x] Custom hostnames
-   [x] Manage TLS settings
-   [x] Zone Lockdown and User-Agent Block rules
-   [ ] Organization Administration
-   [x] [Railgun](https://www.cloudflare.com/railgun/) administration
-   [ ] [Keyless SSL](https://blog.cloudflare.com/keyless-ssl-the-nitty-gritty-technical-details/)
-   [x] [Origin CA](https://blog.cloudflare.com/universal-ssl-encryption-all-the-way-to-the-origin-for-free/)
-   [x] Crypto
-   [x] Load Balancers
-   [x] Firewall Settings

## Licensing

Licensed under the 3-clause BSD license. See the [LICENSE](LICENSE) file for details.
