#!/usr/bin/env bash
#!/bin/bash

rm -rf build
mkdir -p build

# cp -r app/ bootstrap/ config/ routes/ storage/ composer.json build/
cp -r app/ bootstrap/ config/ routes/ composer.json build/

rm build/config/view.php
rm build/app/Console/Commands/BuildCommand.php
rm -rf build/app/Console/Commands/App/

# cp -r app/Overrides/Symfony/Component/Finder/SplFileInfo.php build/vendor/symfony/finder/SplFileInfo.php
# cp -r app/Overrides/Illuminate/Log/LogManager.php build/vendor/laravel/framework/src/Illuminate/Log/LogManager.php
# cp -r app/Overrides/Illuminate/Foundation/Bootstrap/LoadConfiguration.php build/vendor/laravel/framework/src/Illuminate/Foundation/Bootstrap/LoadConfiguration.php
cp bin/ductn build/artisan

# composer config -d build/ platform.php 8.1
composer install -d build/ --no-dev

cd build/vendor
rm -rf */*/tests/ */*/src/tests/ */*/docs/ */*/*.md */*/composer.* */*/phpunit.* */*/.gitignore */*/.*.yml */*/*.xml
cd - >/dev/null

cd build/vendor/symfony/
rm -rf */Symfony/Component/*/Tests/ */Symfony/Component/*/*.md */Symfony/Component/*/composer.* */Symfony/Component/*/phpunit.* */Symfony/Component/*/.gitignore
cd - >/dev/null

# chmod +x bin/phar-composer
# bin/phar-composer build build/ ductn-cli
php -d phar.readonly=off bin/phar-composer build build/ ductn
# chmod +x ductn

rm -rf build
