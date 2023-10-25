<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 dark:text-gray-200 leading-tight">
            {{ __('Danh sách VMs') }}
        </h2>
    </x-slot>

    <div class="container">
        @foreach ($vms as $vm)
            @if ($vm->is_enable)
                @include('admin.vm.vmenable', $vm)
            @else
                @include('admin.vm.vmdisable', $vm)
            @endif
        @endforeach

        @include('admin.vm.new')
    </div>
</x-app-layout>
