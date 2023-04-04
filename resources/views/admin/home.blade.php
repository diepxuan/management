@extends('admin.layout')
@section('main')
    <div class="row">
        <div class="col">
        </div>
        <div class="col">
            <h3>VMs</h3>
            <div class="accordion accordion-flush" id="accordionVms">
                @foreach ($vms as $vm)
                    @include('sys/vm/item', $vm)
                @endforeach
            </div>
        </div>
        <div class="col">
            3 of 3
        </div>
    </div>
@endsection
