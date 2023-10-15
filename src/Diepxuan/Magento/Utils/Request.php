<?php

namespace Diepxuan\Magento\Utils;

use GuzzleHttp\Client;
use GuzzleHttp\HandlerStack;
use GuzzleHttp\Exception\ClientException;
use GuzzleHttp\Exception\ServerException;
use Diepxuan\Magento\Exceptions\MagentoClientException;
use Diepxuan\Magento\Exceptions\MagentoRequestException;


class Request
{
    /**
     * @var \GuzzleHttp\Client
     */
    public $client;

    /**
     * Request constructor.
     *
     * @param null  $token
     * @param array $options
     * @param array $headers
     */
    public function __construct($token = [], $options = [], $headers = [])
    {
        $token = array_replace([
            'consumer_key'    => 'anonymous',
            'consumer_secret' => 'anonymous',
            'token'           => 'anonymous',
            'token_secret'    => 'anonymous',

            'signature_method' => Oauth1::SIGNATURE_METHOD_HMACSHA256,
        ], $token);
        $middleware = new Oauth1($token);
        $stack      = HandlerStack::create();
        $stack->push($middleware);

        $headers = array_merge([
            'Accept'        => 'application/json',
            'Content-Type'  => 'application/json',
        ], $headers);

        $options = array_merge([
            'headers' => $headers,
            'handler' => $stack,
            'auth' => 'oauth',
        ], $options);

        $this->client = new Client($options);
    }

    /**
     * @param $callback
     *
     * @return mixed
     * @throws \Diepxuan\Magento\Exceptions\MagentoClientException
     * @throws \Diepxuan\Magento\Exceptions\MagentoRequestException
     */
    public function handleWithExceptions($callback)
    {
        try {
            return $callback();
        } catch (ClientException $exception) {

            $message = $exception->getMessage();
            $code    = $exception->getCode();

            if ($exception->hasResponse()) {

                $message = (string) $exception->getResponse()->getBody();
                $code    = $exception->getResponse()->getStatusCode();
            }

            throw new MagentoRequestException($message, $code);
        } catch (ServerException $exception) {

            $message = $exception->getMessage();
            $code    = $exception->getCode();

            if ($exception->hasResponse()) {

                $message = (string) $exception->getResponse()->getBody();
                $code    = $exception->getResponse()->getStatusCode();
            }

            throw new MagentoRequestException($message, $code);
        } catch (\Exception $exception) {

            $message = $exception->getMessage();
            $code    = $exception->getCode();

            throw new MagentoClientException($message, $code);
        }
    }
}