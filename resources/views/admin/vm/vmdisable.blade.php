<div vm="{{ $vm_id }}" vmParent="{{ $parent_id }}" class="row mt-3">
    <div class="col border border-secondary-subtle rounded-2">

        <div class="row py-2">
            <h5 class="col text-secondary-emphasis">{{ $name }}</h5>

            <div class="col-auto">
                <form class="d-block" method="post" action="{{ route('admin.vm.update', ['vm' => $vm_id]) }}">
                    @method('PATCH') @csrf
                    <input type="hidden" value="{{ $is_allow ? 0 : 1 }}" name="is_allow" />
                    <button type="submit" class="form-control form-control-sm btn text-primary">
                        <i class="bi bi-power"></i>
                    </button>
                </form>
            </div>
            <div class="col-auto">
                <form class="d-block" method="post" action="{{ route('admin.vm.destroy', ['vm' => $vm_id]) }}">
                    @method('DELETE') @csrf
                    <input type="hidden" value="{{ $vm_id }}" name="vm" />
                    <button type="submit" class="form-control form-control-sm btn text-danger">
                        <i class="bi bi-trash"></i>
                    </button>
                </form>
            </div>
        </div>

        <table class="table">
            <tr>
                <th>public</th>
                <th>private</th>
                <th>gateway</th>
                <th class="text-end">version</th>
            </tr>
            <tr>
                <td class="text-start">{{ $pub_host ?: '-' }}</td>
                <td class="text-start">{{ $pri_host ?: '-' }}</td>
                <td class="text-start">{{ $gateway ?: '-' }}</td>
                <td class="text-end">{{ $version ?: '-' }}</td>
            </tr>
        </table>

        <div vmClients="{{ $vm_id }}" class="d-block ps-5 pe-1 pb-1">
        </div>
    </div>
</div>
