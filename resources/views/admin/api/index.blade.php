<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 dark:text-gray-200 leading-tight">
            {{ __('Danh sách nguồn dữ liệu') }}
        </h2>
    </x-slot>

    <div class="container">
        <div class="row">
            <div class="col-auto">
                <a href="{{ route('admin.api.create') }}" class="form-control form-control-lg btn btn-success">New Api</a>
            </div>
        </div>
        @if (count($apis))
            <table class="table table-sm">
                <tr>
                    <th scope="col">Type</th>
                    <th scope="col">id doanh nghiep</th>
                    <th scope="col">id kho hang</th>
                    <th scope="col">expired</th>
                    <th scope="col"></th>
                </tr>
                @foreach ($apis as $api)
                    <tr>
                        <td scope="col">{{ $api->type }}</td>
                        <td scope="col">{{ $api->businessId }}</td>
                        <td scope="col">{{ $api->depotIds ?: 'tat ca' }}</td>
                        <td scope="col">{{ $api->expiredDateTime->format('H:i:s m/d/Y') }}</td>
                        <td scope="col">
                            <x-row>
                                <form class="col-auto" method="post"
                                    action="{{ route('admin.api.update', ['api' => $api]) }}">
                                    @method('PATCH') @csrf
                                    <input type="hidden" value="1" name="renew" />
                                    <button type="submit" class="form-control form-control-sm btn text-success">
                                        <i class="bi bi-arrow-clockwise"></i>
                                    </button>
                                </form>
                                <form class="col-auto" method="post"
                                    action="{{ route('admin.api.destroy', ['api' => $api]) }}">
                                    @method('DELETE') @csrf
                                    <button type="submit" class="form-control form-control-sm btn text-danger">
                                        <i class="bi bi-trash"></i>
                                    </button>
                                </form>
                            </x-row>
                        </td>
                    </tr>
                @endforeach
            </table>
        @endif
    </div>
</x-app-layout>
