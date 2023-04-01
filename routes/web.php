<?php

use Illuminate\Support\Facades\Route;
use App\Http\Middleware\ClearCache;
/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

// Route::get('/', function () {
//     return view('welcome');
// });

Route::domain("admin.diepxuan.com")->group(function () {
    Route::middleware([ClearCache::class])->group(function () {
        // Route::get('/', function () {
        //     return view('welcome');
        // });

        // Route::get("/{hostname?}/{ip?}", [App\Http\Controllers\Dyndns\HomeController::class, "index"]);
        Route::get("/etc/{conf?}", [App\Http\Controllers\Sys\EnvController::class, "index"]);
    });
});