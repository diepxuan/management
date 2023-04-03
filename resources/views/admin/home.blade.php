@extends('admin.layout')
@section('main')
    <div class="row">
        <div class="col">
        </div>
        <div class="col">
            <h3>VMs</h3>
            <div class="accordion accordion-flush" id="accordionVms">

                <ul class="list-group list-group-flush">
                    @foreach ($vms as $vm)
                        <li class="list-group-item d-flex justify-content-between align-items-center">
                            {{ $vm->name }}
                        </li>
                    @endforeach
                </ul>

            </div>
        </div>
        <div class="col">
            3 of 3
        </div>
    </div>
@endsection
