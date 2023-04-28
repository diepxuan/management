<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 dark:text-gray-200 leading-tight">
            {{ __('Danh sách VMs') }}
        </h2>
    </x-slot>

    <div class="container">
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
    </div>
</x-app-layout>
