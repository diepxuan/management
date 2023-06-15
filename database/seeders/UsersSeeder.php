<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UsersSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run()
    {
        \App\Models\User::updateOrCreate([
            'email' => 'caothu91@gmail.com'
        ], [
            'name' => 'Tran Ngoc Duc',
            'email' => 'caothu91@gmail.com',
            'password' => Hash::make('Ductn@7691'),
        ]);
    }
}