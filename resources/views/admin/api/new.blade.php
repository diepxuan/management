@extends('admin.layout')
@section('main')
    <h1>New Api token</h1>
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
                    class="form-control form-control-lg btn btn-success">
                    Nhanh Api
                </a>
            </td>
        </tr>
    </table>
@endsection
