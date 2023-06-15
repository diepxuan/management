<?php

namespace App\Helpers;

use Illuminate\Database\Eloquent\Model;

class IpaddressHelper extends Model
{
    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'client',
        'server',
    ];

    /**
     * @return mixed Client Ip
     */
    public function getClientAttribute()
    {
        //whether ip is from the share internet
        if (!empty($_SERVER['HTTP_CLIENT_IP'])) {
            $ip = $_SERVER['HTTP_CLIENT_IP'];
        }
        //whether ip is from the proxy
        elseif (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
            $ip = $_SERVER['HTTP_X_FORWARDED_FOR'];
        }
        //whether ip is from the remote address
        else {
            $ip = $_SERVER['REMOTE_ADDR'];
        }
        return $ip;
    }

    /**
     * @return mixed Server Ip
     */
    public function getServerAttribute()
    {
        return $_SERVER['SERVER_ADDR'];
    }

    /**
     * @return mixed Current public Ip of server
     */
    public function getCurrentIp($ipUrl = 'http://ipv4.icanhazip.com')
    {
        if (!isset($_currentIp) || empty($_currentIp) || !$_currentIp) {
            $_currentIp = file_get_contents($ipUrl);
        }
        $result = $_currentIp;
        if (empty($result)) {
            return false;
        }

        return $result;
    }
}
