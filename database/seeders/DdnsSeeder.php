<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Dyndns\Ddns;

class DdnsSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        Ddns::updateOrCreate([
            'email' => 'caothu91@gmail.com',
            'api' => '01c88838aa999cf0610905a1662022138c759',
            'apiUrl' => 'https://api.cloudflare.com/client/v4',
        ], [
            'email' => 'caothu91@gmail.com',
            'api' => '01c88838aa999cf0610905a1662022138c759',
            'apiUrl' => 'https://api.cloudflare.com/client/v4',
        ]);
    }
}
