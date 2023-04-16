@extends('admin.layout')
@section('main')
    <h1>Danh sách sản phẩm</h1>

    @if (count($apis))
        <form class="d-block" method="post" action="{{ route('catalog.product.index') }}">
            @method('POST') @csrf
            <div class="form-check form-switch">
                <input class="form-check-input" type="checkbox" role="switch" id="api_base" name="api[base]" checked disabled>
                <label class="form-check-label" for="api_base">Dữ liệu gốc</label>
            </div>

            @foreach ($apis as $api)
                <div class="form-check form-switch">
                    <input class="form-check-input" type="checkbox" role="switch" name="api[{{ $api->id }}]"
                        {{ $api->enable ? 'checked' : '' }} id="api_{{ $api->id }}" onchange="this.form.submit()">
                    <label class="form-check-label" for="api_{{ $api->id }}">Đồng bộ từ {{ $api->type }}</label>
                </div>
            @endforeach

        </form>
    @endif

    @if ($products)
        <table class="table">
            <tr>
                <th scope="col">#</th>
                <th scope="col">code</th>
                <th scope="col">tên</th>
                <th scope="col">giá bán</th>
                <th scope="col">loại sản phẩm</th>
                <th scope="col">thương hiệu</th>
            </tr>
            @foreach ($products as $product)
                <tr>
                    <td scope="col">{{ $loop->index + 1 }}</td>
                    <td scope="col">{{ $product->code }}</td>
                    <td scope="col">{{ $product->name }}</td>
                    <td scope="col">{{ $product->price }}</td>
                    <td scope="col">{{ $product->typeName }}</td>
                    <td scope="col">{{ $product->brandName }}</td>
                </tr>
            @endforeach
        </table>
        {{ $products->links() }}
    @endif
@endsection
