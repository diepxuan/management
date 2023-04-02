<div class="accordion-item">
    <h2 class="accordion-header" id="heading{{ $id }}">
        <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse"
            data-bs-target="#collapse{{ $id }}" aria-expanded="false"
            aria-controls="collapse{{ $id }}">
            {{ $vm_id }}
        </button>
    </h2>
    <div id="collapse{{ $id }}" class="accordion-collapse collapse"
        aria-labelledby="heading{{ $id }}" data-bs-parent="#accordionVms">
        <div class="accordion-body">
            <ul class="list-group list-group-flush">
                <li class="list-group-item d-flex justify-content-between align-items-center">
                    {{ $name }}
                </li>
                <li class="list-group-item d-flex justify-content-between align-items-center">
                    {{ $pri_host }}
                </li>
                <li class="list-group-item d-flex justify-content-between align-items-center">
                    {{ $pub_host }}
                </li>
            </ul>
        </div>
    </div>
</div>
