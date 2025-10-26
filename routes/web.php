<?php

use Illuminate\Support\Facades\Route;

// Redirect default login to admin login
Route::redirect('/login', '/admin/login')->name('login');
