@extends('layouts.app')

@section('content')
    @if (session('status'))
        <div class="alert alert-success" role="alert">
            {{ session('status') }}
        </div>
    @endif

    <main class="container-fluid">
        @yield('main')
    </main>

    @isset($template)
        @include($template)
    @endisset
@endsection
