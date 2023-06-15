@props(['disabled' => false])

<div class="col">
    <input {{ $disabled ? 'disabled' : '' }} {!! $attributes->merge(['class' => 'form-control']) !!}>
</div>
