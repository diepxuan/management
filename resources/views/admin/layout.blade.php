@extends('layouts.app')

@section('content')
    @if (session('status'))
        <div class="alert alert-success" role="alert">
            {{ session('status') }}
        </div>
    @endif

    <main class="container-fluid">
        <div class="row">
            <div class="col-md-2">
                <ul class="nav flex-column ">
                    <li class="nav-item">
                        <a class="nav-link" href="{{ url('/') }}">DashBoard</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#">Link</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#">Link</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link disabled">Disabled</a>
                    </li>
                </ul>
            </div>
            <div class="col-md-9 align-self-end">
                @yield('main')
            </div>
        </div>
    </main>

    @isset($template)
        @include($template)
    @endisset
@endsection
