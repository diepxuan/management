<?php

error_reporting(E_ALL);
ini_set('error_reporting', E_ALL);
ini_set('display_errors', 1);

date_default_timezone_set("Asia/Ho_Chi_Minh");

class DDNS extends stdClass
{

  private $zones = Array();
  private $_currentIp = false;

  public $email = 'caothu91@gmail.com';
  public $api = '389205e67f635944870279ea7229994968d69';
  public $apiUrl = 'https://api.cloudflare.com/client/v4';
  public $ipUrl = 'http://ipv4.icanhazip.com';

  function __construct(
    $email = 'caothu91@gmail.com',
    $api = '389205e67f635944870279ea7229994968d69',
    $apiUrl = 'https://api.cloudflare.com/client/v4',
    $ipUrl = 'http://ipv4.icanhazip.com'
  ) {
    $this->email = $email;
    $this->api = $api;
    $this->apiUrl = $apiUrl;
    $this->ipUrl = $ipUrl;
  }

  function getCurrentIp($ipUrl = 'http://ipv4.icanhazip.com')
  {
    if( !isset($_currentIp) || empty($_currentIp) || !$_currentIp ) {
      $_currentIp = file_get_contents($ipUrl);
    }
    $result = $_currentIp;
    if( empty($result) ) {
      return false;
    }
    return $result;
  }

  function userDetail($fields = null) {
    if(isset($fields) && !empty($fields) && $fields != null) {
      $result = $this->curlRequest('/user', $fields, 'PATCH');
      return $result;
    }
    $result = $this->curlRequest('/user');
    return $result;
  }

  function userBilling() {
    $result = $this->curlRequest('/user/billing/profile');
    return $result;
  }

  function userBillingHistory() {
    $result = $this->curlRequest('/user/billing/history');
    return $result;
  }

  function userBillingApp() {
    $result = $this->curlRequest('/user/billing/subscriptions/apps');
    return $result;
  }

  function userBillingAppZone() {
    $result = $this->curlRequest('/user/billing/subscriptions/zones');
    return $result;
  }

  function zone($identifier = '') {
    if (isset($identifier) && !empty($identifier) && $identifier != '') {
      $result = $this->curlRequest(sprintf('/zones/%s', $identifier));
    } else {
      $result = $this->curlRequest('/zones');
    }

    return $result;
  }

  function dns($zone_identifier = '', $identifier = '')
  {
    if (isset($zone_identifier) && !empty($zone_identifier) && $zone_identifier != '') {
      if (isset($identifier) && !empty($identifier) && $identifier != '') {
        $result = $this->curlRequest(sprintf('/zones/%s/dns_records/%s', $zone_identifier, $identifier));
        return $result;
      }

      $dns_records = $this->curlRequest(sprintf('/zones/%s/dns_records?type=A', $zone_identifier));
      $dns_records = $dns_records->result;
      $result = Array();
      foreach ($dns_records as $key => $dns_record) {
        $identifier = $dns_record->id;
        $result[$identifier] = $dns_record;
      }
      return $result;
    }
    $zones = $this->zone();
    $zones = $zones->result;
    foreach ($zones as $key => $zone) {
      $zone_identifier = $zone->id;
      $this->zones[$zone_identifier] = $this->dns($zone_identifier);
    }
    return $this->zones;
  }

  function run()
  {
    $this->zones = $this->dns();
    $results = Array();
    foreach ($this->zones as $zone_identifier => $identifiers) {
      foreach ($identifiers as $identifier => $fields) {
        $_content_old = $fields->content;
        $_content_new = urlencode( trim($this->getCurrentIp(), " \t\n\r\0\x0B") );
        if($_content_old != $_content_new) {
          $fields->content = $_content_new;
          $fields->data = new stdClass();
          unset($fields->meta);
          // $this->debug( $fields );
          $result = $this->curlRequest(sprintf('/zones/%s/dns_records/%s', $zone_identifier, $identifier), $fields, 'PUT');
          // array_push($results, $result);
          $results[$_content_old] = $result;
          // $this->debug( $result );
        }
      }
    }

    $this->debug( $results );
    return $results;
  }

  function curlRequest($url, $fields = null, $method = 'POST') {
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $this->apiUrl . $url);
    curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, 0);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, 0);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($ch, CURLOPT_HTTPHEADER, array(
        'X-Auth-Email: ' . $this->email,
        'X-Auth-Key: ' . $this->api,
        'Content-Type: application/json',
    ));

    if(isset($fields) && !empty($fields)) {
      $fields_string = json_encode($fields);

      if($method != 'POST') {
        curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $method);
      } else {
        curl_setopt($ch, CURLOPT_POST, count($fields));
      }
      curl_setopt($ch, CURLOPT_POSTFIELDS, $fields_string);
    }

    $result = curl_exec($ch);
    if ( curl_errno($ch) ) {
      $this->debug( curl_error($ch) );
    }
    curl_close($ch);
    return json_decode($result);
  }

  function debug($value = '')
  {
    echo '<pre>';
    print_r($value);
    echo '</pre>';
  }
}

$app = new DDNS(
  $email = 'caothu91@gmail.com',
  $api = '389205e67f635944870279ea7229994968d69',
  $apiUrl = 'https://api.cloudflare.com/client/v4',
  $ipUrl = 'http://ipv4.icanhazip.com'
);

echo $app->getCurrentIp();
$app->run();

exit;
