<div vm zclass="row row-cols-auto">
    <div class="col">
        <form class="d-block" method="post" action="{{ route('admin.vm.update', ['vm' => 'new']) }}">
            @method('PATCH') @csrf
            <div class="card border-success" style="width: 18rem;">
                <div class="card-body">
                    <h5 class="card-title">
                        <input name="vm_id" class="form-control form-control-sm" />
                    </h5>
                    <table class="table card-text">
                        <tr>
                            <td>private</td>
                            <td><input name="pri_host" class="form-control form-control-sm" /></td>
                        </tr>
                        <tr>
                            <td>parent</td>
                            <td>
                                <select name="parent_id" class="form-select form-select-sm">
                                    <option value="">none</option>
                                    @foreach ($vms as $_parent)
                                        <option value="{{ $_parent->vm_id }}">
                                            {{ $_parent->name }}
                                        </option>
                                    @endforeach
                                </select>
                            </td>
                        </tr>
                        <tr>
                            <td>TCP</td>
                            <td>
                                <input name="port[tcp]" class="form-control form-control-sm" />
                            </td>
                        </tr>
                        <tr>
                            <td>UDP</td>
                            <td>
                                <input name="port[udp]" class="form-control form-control-sm" />
                            </td>
                        </tr>
                        <tr>
                            <td>version</td>
                            <td>
                                <input name="version" class="form-control form-control-sm" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="card-footer bg-transparent">
                    <div class="row justify-content-between">
                        <div class="col-auto">
                            <button type="submit" class="form-control form-control-sm btn text-success">
                                <i class="bi bi-upload"></i>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </form>
    </div>
</div>
