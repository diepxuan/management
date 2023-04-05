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

    Route::middleware([
        ClearCache::class,
    ])->group(function () {

        Route::get('/', [App\Http\Controllers\Admin\HomeController::class, "index"]);

        Route::get('/etc/{env}/{vm_id}', [App\Http\Controllers\Sys\EnvController::class, "showByVm"]);

        Route::resources([
            'etc' => App\Http\Controllers\Sys\EnvController::class,
            'vm' => App\Http\Controllers\Sys\VmController::class,
        ]);

        Route::namespace('App\Http\Controllers\Admin')->prefix('admin')->name('admin.')->group(function () {
            Route::resource('vm', VmController::class);
        });
    });
});
