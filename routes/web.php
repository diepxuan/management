<?php

use Illuminate\Support\Facades\Route;
use App\Http\Middleware\ClearCache;
use Illuminate\Http\Request;

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
        'guest',
        ClearCache::class,
    ])->group(function () {

        Route::get('/etc/{env}/{vm}', [App\Http\Controllers\Sys\EnvController::class, "showByVm"]);

        Route::resources([
            'etc' => App\Http\Controllers\Sys\EnvController::class,
            'vm' => App\Http\Controllers\Sys\VmController::class,
        ]);
    });

    Route::middleware(
        'auth',
        ClearCache::class,
    )->group(function () {

        Route::get('/', [App\Http\Controllers\Admin\HomeController::class, "index"]);
        Route::get('/dashboard', [App\Http\Controllers\Admin\HomeController::class, "index"]);
        Route::match(array('GET', 'POST'), '/api/{type}', [App\Http\Controllers\Admin\ApiController::class, "token"])->name("api.new");

        Route::namespace('App\Http\Controllers\Admin')->prefix('admin')->name('admin.')->group(function () {
            Route::resource('vm', VmController::class);
            Route::resource('api', ApiController::class);
        });

        Route::namespace('App\Http\Controllers\Catalog')->prefix('catalog')->name('catalog.')->group(function () {
            Route::resource('product', ProductController::class);
        });
    });
});


Route::middleware('auth')->group(function () {
    Route::get('/profile', [App\Http\Controllers\ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [App\Http\Controllers\ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [App\Http\Controllers\ProfileController::class, 'destroy'])->name('profile.destroy');
});

require __DIR__ . '/auth.php';