@extends('admin.layout')
@section('main')
    <h1>Danh sách sản phẩm</h1>

    @if (count($apis))
        @foreach ($apis as $api)
            <div class="row">
                <div class="col-auto">
                    <form class="d-block" method="post" action="{{ route('catalog.product.sync', ['api' => $api]) }}">
                        @method('POST') @csrf
                        <input type="hidden" value="{{ $api->id }}" name="api_id" />
                        <button type="submit" class="form-control form-control-lg btn btn-success">
                            Đồng bộ từ {{ $api->type }}
                        </button>
                    </form>
                </div>
            </div>
        @endforeach
    @endif

    @if (count($products))
        <table class="table">
            <tr>
                <th scope="col">mã</th>
                <th scope="col">tên</th>
                <th scope="col">id kho hang</th>
                <th scope="col">expired</th>
            </tr>
            @foreach ($products as $product)
                <tr>
                    <td scope="col">{{ $product->type }}</td>
                    <td scope="col">{{ $product->businessId }}</td>
                    <td scope="col">{{ $product->depotIds ?: 'tat ca' }}</td>
                    <td scope="col">{{ $product->expiredDateTime }}</td>
                </tr>
            @endforeach
        </table>
    @endif
@endsection
