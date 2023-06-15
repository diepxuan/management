<x-guest-layout>
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-8">
                <div class="card">

                    <!-- Session Status -->
                    <x-auth-session-status class="mb-4" :status="session('status')" />

                    <div class="card-header">{{ __('Login') }}</div>

                    <div class="card-body">
                        <form method="POST" action="{{ route('login') }}">
                            @csrf

                            <!-- Email Address -->
                            <div class="mb-3 row">
                                <x-input-label for="email" :value="__('Email')" class="col-sm-2" />
                                <x-text-input id="email" class="" type="email" name="email"
                                    :value="old('email')" required autofocus autocomplete="username" />

                                <x-input-error :messages="$errors->get('email')" class="mt-2" />
                            </div>

                            <!-- Password -->
                            <div class="mb-3 row">
                                <x-input-label for="password" class="col-sm-2" :value="__('Password')" />
                                <x-text-input id="password" class="" type="password" name="password" required
                                    autocomplete="current-password" />

                                <x-input-error :messages="$errors->get('password')" class="mt-2" />
                            </div>

                            <!-- Remember Me -->
                            <fieldset class="row mb-3">
                                <legend class="col-form-label col-sm-2 pt-0"></legend>
                                <div class="col">
                                    <div class="form-check">
                                        <x-input-label class="pt-0" for="remember_me" :value="__('Remember me')" />
                                        <x-checkbox class="pt-0" id="remember_me" name="remember" />

                                    </div>
                                </div>
                            </fieldset>

                            <div class="row mb-3">
                                <legend class="col-form-label col-sm-2 pt-0"></legend>

                                <div class="col">
                                    <div class="row row-cols-auto justify-content-around">
                                        <x-primary-button class="col-auto">
                                            {{ __('Log in') }}
                                        </x-primary-button>


                                        @if (Route::has('password.request'))
                                            <a href="{{ route('password.request') }}" class="col-auto">
                                                {{ __('Forgot your password?') }}
                                            </a>
                                        @endif
                                    </div>
                                </div>
                            </div>
                        </form>
                    </div>

                </div>
            </div>
        </div>
    </div>
</x-guest-layout>
