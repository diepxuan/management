@extends('admin.layout')
@section('main')
    <h1>Danh sách nguồn dữ liệu</h1>
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
            </tr>
            @foreach ($apis as $api)
                <tr>
                    <td scope="col">{{ $api->type }}</td>
                    <td scope="col">{{ $api->businessId }}</td>
                    <td scope="col">{{ $api->depotIds ?: 'tat ca' }}</td>
                    <td scope="col">{{ $api->expiredDateTime }}</td>
                </tr>
            @endforeach
        </table>
    @endif
@endsection
