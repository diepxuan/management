<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 dark:text-gray-200 leading-tight">
            {{ __('Thêm nguồn dữ liệu') }}
        </h2>
    </x-slot>

    <div class="container">
        <table class="table">
            <tr>
                <th scope="col">#</th>
                <th scope="col">Type</th>
                <th scope="col"></th>
            </tr>
            <tr>
                <td scope="col">1</td>
                <td scope="col">Nhanh</td>
                <td scope="col">
                    <a href="https://nhanh.vn/oauth?version=2.0&appId=72370&returnLink=https://admin.diepxuan.com/api/nhanh"
                        class="btn btn-success">
                        Get Api
                    </a>
                </td>
            </tr>
            <tr>
                <td scope="col">2</td>
                <td scope="col">Magento2</td>
                <td scope="col">
                    <form class="row row-cols-lg-auto g-3 align-items-center" method="post"
                        action="{{ route('api.new', ['type' => 'magento2']) }}">
                        @method('POST') @csrf
                        <div class="col-12">
                            <label class="visually-hidden" for="apiMagento2Url">Url</label>
                            <div class="input-group">
                                <div class="input-group-text">Url</div>
                                <input type="text" class="form-control" id="apiMagento2Url"
                                    placeholder="https://www.domain.com">
                            </div>
                        </div>
                        <div class="col-12">
                            <label class="visually-hidden" for="apiMagento2Username">Username</label>
                            <div class="input-group">
                                <div class="input-group-text">Acc</div>
                                <input type="text" class="form-control" id="apiMagento2Username"
                                    placeholder="Username">
                            </div>
                        </div>
                        <div class="col-12">
                            <label class="visually-hidden" for="apiMagento2Password">Password</label>
                            <div class="input-group">
                                <div class="input-group-text">Pwd</div>
                                <input type="text" class="form-control" id="apiMagento2Password"
                                    placeholder="Password">
                            </div>
                        </div>
                        <div class="col-12">
                            <button type="submit" class="btn btn-success">Get Api</button>
                        </div>
                    </form>
                </td>
            </tr>
        </table>
    </div>
</x-app-layout>
