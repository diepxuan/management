<div class="col">
    <div class="vm card border-success" style="width: 18rem;">
        <div class="card-body">
            <h5 class="card-title text-success">{{ $name }}</h5>
            <table class="table card-text">
                <tr>
                    <td>private</td>
                    <td class="text-end">{{ $pri_host ?: '-' }}</td>
                </tr>
                <tr>
                    <td>public</td>
                    <td class="text-end">{{ $pub_host ?: '-' }}</td>
                </tr>
                <tr>
                    <td>gateway</td>
                    <td class="text-end">{{ $gateway ?: '-' }}</td>
                </tr>
                <tr>
                    <td>version</td>
                    <td class="text-end">{{ $version ?: '-' }}</td>
                </tr>
            </table>
        </div>
        <div class="card-footer bg-transparent">
            <div class="row justify-content-between">
                <div class="col-auto">
                    <form class="d-block" method="post" action="{{ route('admin.vm.update', ['vm' => $id]) }}">
                        @method('PATCH') @csrf
                        <input type="hidden" value="{{ !$is_allow }}" name="is_allow" />
                        <button type="submit" class="form-control form-control-sm btn text-danger">
                            <i class="bi bi-power"></i>
                        </button>
                    </form>
                </div>
                <div class="col-auto">
                    <button type="submit" class="form-control form-control-sm btn">
                        <i class="bi bi-gear-fill"></i>
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>
