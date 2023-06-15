@props(['checked' => false])

<input {{ $checked ? 'checked' : '' }} type="checkbox" {!! $attributes->merge(['class' => 'form-check-input']) !!} />
