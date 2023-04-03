<div class="col">
    <div class="vm card border-disable text-black-50" style="width: 18rem;">
        <div class="card-body">
            <h5 class="card-title">{{ $name }}</h5>
            <p class="card-text">
                host private <span class="text-disable">{{ $pri_host }}</span>
                <br />
                host public <span class="text-disable">{{ $pub_host }}</span>
            </p>
        </div>
        <div class="card-footer bg-transparent">
            <div class="row justify-content-between">
                <div class="col-auto">
                    <form class="d-block" method="post" action="{{ route('admin.vm.update', ['vm' => $id]) }}">
                        @method('PATCH') @csrf
                        <input type="hidden" value="{{ $is_allow ? 0 : 1 }}" name="is_allow" />
                        <button type="submit" class="form-control form-control-sm btn text-primary">
                            <i class="bi bi-power"></i>
                        </button>
                    </form>
                </div>
                <div class="col-auto">
                    <form class="d-block" method="post" action="{{ route('admin.vm.destroy', ['vm' => $id]) }}">
                        @method('DELETE') @csrf
                        <input type="hidden" value="{{ $id }}" name="vm" />
                        <button type="submit" class="form-control form-control-sm btn text-danger">
                            <i class="bi bi-trash"></i>
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
