@extends('admin.layout')
@section('main')
    <h3>VMs</h3>
    @foreach ($vms as $vm)
        <div class="row row-cols-auto">
            @if ($vm->is_allow)
                @include('sys/vm/item', $vm)
            @else
                @include('sys/vm/disable', $vm)
            @endif
        </div>
    @endforeach
    @include('sys/vm/new')
@endsection
