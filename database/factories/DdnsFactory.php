<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use App\Models\Dyndns\Ddns;

class DdnsFactory extends Factory
{
    /**
     * The name of the factory's corresponding model.
     *
     * @var string
     */
    protected $model = Ddns::class;

    /**
     * Define the model's default state.
     *
     * @return array
     */
    public function definition()
    {
        return [
            'email' => 'caothu91@gmail.com',
            'api' => '01c88838aa999cf0610905a1662022138c759',
            'apiUrl' => 'https://api.cloudflare.com/client/v4',
        ];
    }
}
