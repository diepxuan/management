<?php

namespace App\Helpers;

use Illuminate\Support\Str as Helper;

class Str extends Helper
{

    /**
     * @param $str
     * @return mixed
     */
    public static function stripcomments($str)
    {
        $str = preg_replace('/^#.*/', '', $str);
        $str = trim($str);
        return $str;
    }

    /**
     * @param $str
     * @return mixed
     */
    public static function sanitizeString($str)
    {
        $str = transliterator_transliterate('Any-Latin; Latin-ASCII; [\u0080-\u7fff] remove', $str);
        $str = preg_replace('/[^-\w]+/', '_', $str);
        $str = preg_replace('/_+/', '_', $str);
        $str = self::upper($str);
        $str = strtoupper($str);
        $str = self::trim($str, '_');

        return $str;
    }
}