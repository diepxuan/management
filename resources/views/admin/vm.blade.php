@extends('admin.layout')
@section('main')
    <h3>VMs</h3>
    <div class="row row-cols-auto">
        @foreach ($vms as $vm)
            @if ($vm->is_allow)
                @include('sys/vm/item', $vm)
            @else
                @include('sys/vm/itemdisable', $vm)
            @endif
        @endforeach
        <div class="col">
        </div>
    </div>
@endsection
