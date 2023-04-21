@extends('catalog.layout')
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

            <div class="form-check form-switch">
                <input type="hidden" value="{{ session('is_all') ? 0 : 1 }}" name="is_all" />
                <input class="form-check-input" type="checkbox" role="switch" id="is_all"
                    {{ session('is_all') ? 'checked' : null }} onchange="this.form.submit()">
                <label class="form-check-label" for="is_all">Hiển thị tất cả</label>
            </div>

        </form>
    @endif

    @if ($products)
        <table class="table table-sm">
            <tr>
                <th scope="col">nhanh Id</th>
                <th scope="col">code</th>
                <th scope="col">tên</th>
                <th scope="col">giá bán</th>
                <th scope="col">loại sản phẩm</th>
                <th scope="col">thương hiệu</th>
            </tr>
            @foreach ($products as $product)
                <tr>
                    <td scope="col">{{ $product->nhanh_id }}</td>
                    <td scope="col">{{ $product->code }}</td>
                    <td scope="col">{{ $product->name }}</td>
                    <td scope="col">{{ $product->price }}</td>
                    <td scope="col">{{ $product->typeName }}</td>
                    <td scope="col">{{ $product->brandName }}</td>
                </tr>
            @endforeach
        </table>
        @if (!session('is_all'))
            {{ $products->links() }}
        @endif
    @endif
@endsection
