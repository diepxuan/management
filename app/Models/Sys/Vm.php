<?php

/**
 * @copyright © 2023 DiepXuan. All rights reserved.
 * @author Tran Ngoc Duc <caothu91@gmail.com>
 *
 * Created on Thu May 25 2023 16:29:59
 */

namespace App\Models\Sys;

use App\Helpers\Str;
use App\Models\Admin\Ddns;
use App\Models\Sys\Env\Domain;
use Illuminate\Support\Facades\Log;
use Diepxuan\System\Vm as Model;
use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Vm extends Model
{
    use HasFactory;
}
