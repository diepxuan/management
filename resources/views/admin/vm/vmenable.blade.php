<div vm="{{ $vm_id }}" vmParent="{{ $parent_id }}" class="row mt-3">
    <div class="col border border-success rounded-2">

        <div class="row py-2">
            <h5 class="col text-success">{{ $name }}</h5>

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
                <td class="text-end">
                    {{ $updated_at ? (new \Carbon\Carbon($updated_at))->format('Y-m-d H:i') : '-' }}
                </td>
            </tr>
            <tr class="d-none" vmSetting="{{ $vm_id }}">
                <td>{{ _('ddns') }}</td>
                <td class="text-end">
                    <form class="d-block" method="post" action="{{ route('admin.vm.update', ['vm' => $vm_id]) }}">
                        @method('PATCH') @csrf
                        <select name="ddnses[]" onchange="this.form.submit()" multiple
                            class="form-select form-select-sm" aria-label=".form-select-sm">
                            @foreach ($DdnsLst as $_ddns)
                                <option value="{{ $_ddns->id }}"
                                    {{ !in_array($_ddns->id, $vm->ddnses->pluck('id')->all()) ?: 'selected' }}>
                                    {{ $_ddns->service }}
                                </option>
                            @endforeach
                        </select>
                    </form>
                </td>
            </tr>
            <tr class="d-none" vmSetting="{{ $vm_id }}">
                <td>parent</td>
                <td class="text-end">
                    <form class="d-block" method="post" action="{{ route('admin.vm.update', ['vm' => $vm_id]) }}">
                        @method('PATCH') @csrf
                        <select name="parent_id" onchange="this.form.submit()" class="form-select form-select-sm"
                            aria-label=".form-select-sm">
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
                    <form class="d-block" method="post" action="{{ route('admin.vm.update', ['vm' => $vm_id]) }}">
                        @method('PATCH') @csrf
                        <input name="port[tcp]" class="form-control form-control-sm" onchange="this.form.submit()"
                            value="{{ $port['tcp'] }}">
                    </form>
                </td>
            </tr>
            <tr class="d-none" vmSetting="{{ $vm_id }}">
                <td>UDP</td>
                <td class="text-end">
                    <form class="d-block" method="post" action="{{ route('admin.vm.update', ['vm' => $vm_id]) }}">
                        @method('PATCH') @csrf
                        <input name="port[udp]" class="form-control form-control-sm" onchange="this.form.submit()"
                            value="{{ $port['udp'] }}">
                    </form>
                </td>
            </tr>
        </table>

        <div vmClients="{{ $vm_id }}" class="d-block ps-5 pe-1 pb-1">
        </div>
    </div>
</div>
