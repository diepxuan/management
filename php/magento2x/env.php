<?php
return array (
  'backend' =>
  array (
    'frontName' => 'admin',
  ),
  'crypt' =>
  array (
    'key' => '3252ea5de9205d01c13ed65dd233559d',
  ),
  'session' =>
  array (
    'save' => 'files',
  ),
  'db' =>
  array (
    'table_prefix' => '',
    'connection' =>
    array (
      'indexer' =>
      array (
        'host' => 'master_connect',
        'dbname' => 'magento',
        'username' => 'username',
        'password' => 'password',
        'active' => '1',
        'persistent' => NULL,
      ),
      'default' =>
      array (
        'host' => 'master_connect',
        'dbname' => 'magento',
        'username' => 'username',
        'password' => 'password',
        'active' => '1',
      ),
    ),
  ),
  'db' =>
  array (
    'table_prefix' => '',
    'connection' =>
    array (
      'indexer' =>
      array (
        'host' => 'master_connect',
        'dbname' => 'magento',
        'username' => 'username',
        'password' => 'password',
        'active' => '1',
        'persistent' => NULL,
      ),
      'default' =>
      array (
        'host' => 'master_connect',
        'dbname' => 'magento',
        'username' => 'username',
        'password' => 'password',
        'active' => '1',
      ),
    ),
    'slave_connection' =>
    array (
      'default' =>
      array (
        'host' => 'slave_connect',
        'dbname' => 'magento',
        'username' => 'username',
        'password' => 'password',
        'active' => '1',
      ),
    ),
    'table_prefix' => '',
  ),
  'resource' =>
  array (
    'default_setup' =>
    array (
      'connection' => 'default',
    ),
  ),
  'x-frame-options' => 'SAMEORIGIN',
  'MAGE_MODE' => 'default',
);
