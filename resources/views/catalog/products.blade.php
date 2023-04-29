<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 dark:text-gray-200 leading-tight">
            {{ __('Danh sách sản phẩm') }}
        </h2>
    </x-slot>

    <div class="container-fluid">

        @if (count($apis))
            <form class="d-block" method="post" action="{{ route('catalog.product.index') }}">
                @method('POST') @csrf
                <div class="form-check form-switch">
                    <input class="form-check-input" type="checkbox" role="switch" id="api_base" name="api[base]" checked
                        disabled>
                    <label class="form-check-label" for="api_base">Dữ liệu gốc</label>
                </div>

                <div class="form-check form-switch">
                    <input class="form-check-input" type="checkbox" role="switch" name="is_all" id="is_all"
                        {{ session('is_all') ? 'checked' : null }} onchange="this.form.submit()">
                    <label class="form-check-label" for="is_all">Hiển thị tất cả</label>
                </div>

                <x-row class="row-cols-auto">
                    @foreach ($apis as $api)
                        <div class="col-auto">
                            <button type="submit" name="api[]" value="{{ $api->id }}"
                                class="btn btn-primary mb-3">
                                Đồng bộ từ {{ $api->type }}
                            </button>
                        </div>
                    @endforeach
                </x-row>
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
    </div>
</x-app-layout>
