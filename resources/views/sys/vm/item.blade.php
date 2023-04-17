<div vm="{{ $vm_id }}" vmParent="{{ $parent_id }}" class="row row-cols-auto">
    <div class="col">
        <div class="card border-success" style="width: 18rem;">
            <div class="card-body">
                <h5 class="card-title text-success">{{ $name }}</h5>
                <table class="table card-text">
                    <tr>
                        <td>private</td>
                        <td class="text-end">{{ $pri_host ?: '-' }}</td>
                    </tr>
                    <tr class="d-none" vmSetting="{{ $vm_id }}">
                        <td>public</td>
                        <td class="text-end">{{ $pub_host ?: '-' }}</td>
                    </tr>
                    <tr class="d-none" vmSetting="{{ $vm_id }}">
                        <td>gateway</td>
                        <td class="text-end">{{ $gateway ?: '-' }}</td>
                    </tr>
                    <tr class="d-none" vmSetting="{{ $vm_id }}">
                        <td>parent</td>
                        <td class="text-end">
                            <form class="d-block" method="post"
                                action="{{ route('admin.vm.update', ['vm' => $vm_id]) }}">
                                @method('PATCH') @csrf
                                <select name="parent_id" onchange="this.form.submit()"
                                    class="form-select form-select-sm" aria-label=".form-select-sm">
                                    <option value="" {{ $parent_id ?: 'selected' }}>none</option>
                                    @foreach ($vms as $_parent)
                                        @if ($_parent->vm_id != $vm_id)
                                            <option value="{{ $_parent->vm_id }}"
                                                {{ $vm->parent->vm_id != $_parent->vm_id ?: 'selected' }}>
                                                {{ $_parent->name }}
                                            </option>
                                        @endif
                                    @endforeach
                                </select>
                            </form>
                        </td>
                    </tr>
                    <tr class="d-none" vmSetting="{{ $vm_id }}">
                        <td>TCP</td>
                        <td class="text-end">
                            <form class="d-block" method="post"
                                action="{{ route('admin.vm.update', ['vm' => $vm_id]) }}">
                                @method('PATCH') @csrf
                                <input name="port[tcp]" class="form-control form-control-sm"
                                    onchange="this.form.submit()" value="{{ $port['tcp'] }}">
                            </form>
                        </td>
                    </tr>
                    <tr class="d-none" vmSetting="{{ $vm_id }}">
                        <td>UDP</td>
                        <td class="text-end">
                            <form class="d-block" method="post"
                                action="{{ route('admin.vm.update', ['vm' => $vm_id]) }}">
                                @method('PATCH') @csrf
                                <input name="port[udp]" class="form-control form-control-sm"
                                    onchange="this.form.submit()" value="{{ $port['udp'] }}">
                            </form>
                        </td>
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
                        <form class="d-block" method="post" action="{{ route('admin.vm.update', ['vm' => $vm_id]) }}">
                            @method('PATCH') @csrf
                            <input type="hidden" value="{{ !$is_allow }}" name="is_allow" />
                            <button type="submit" class="form-control form-control-sm btn text-danger">
                                <i class="bi bi-power"></i>
                            </button>
                        </form>
                    </div>
                    <div class="col-auto">
                        <button type="button" vmSettingBtn class="form-control form-control-sm btn">
                            <i class="bi bi-gear-fill"></i>
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div vmClients="{{ $vm_id }}" class="col">
    </div>
</div>
