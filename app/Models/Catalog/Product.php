<?php

namespace App\Models\Catalog;

use Illuminate\Support\Facades\Log;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use App\Models\Sys\Env\Domain;

class Product extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'nhanh_id',
        'nhanh_categoryId',
        'nhanh_parentId',
        'code',             // Mã sản phẩm
        'name',             // Tên sản phẩm
        'otherName',        // Tên khác của sản phẩm

        'importPrice',      // Giá nhập
        'oldPrice',         // Giá cũ
        'price',            // Giá bán lẻ
        'wholesalePrice',   // Giá bán buôn
        'vat',              // % thuế giá trị gia tăng (VD: 10)

        'image',            // Đường dẫn tuyệt đối của ảnh đại diện
        'images',           // Đường dẫn tuyệt đối của các ảnh khác của sản phẩm
        'status',
        'previewLink',      // Link chi tiết của sản phẩm trên website (if status is Active)
        'showHot',          // Sản phẩm được đánh dấu là sản phẩm hot
        'showNew',          // Sản phẩm được đánh dấu là sản phẩm mới
        'showHome',         // Sản phẩm được đánh dấu hiển thị ở trang chủ

        'unit',             // Đơn vị tính
        'width',            // cm
        'height',           // cm
        'length',           // cm
        'shippingWeight',   // gram

        'warrantyAddress',  // Địa chỉ bảo hành
        'warrantyPhone',    // Số điện thoại bảo hành
        'warranty',         // Số tháng bảo hành

        'brandId',          // ID thương hiệu
        'brandName',        // Tên thương hiệu
        'countryName',      // Xuất xứ

        'typeId',           // ID loại sản phẩm
        'typeName',         // Loại sản phẩm

        'importType',       // ID Kiểu nhập kho
        'importTypeLabel',  // Tên kiểu nhập kho

        'avgCost',          // Giá vốn sản phẩm
    ];

    /**
     * Make attributes available in the json response.
     *
     * @var array
     */
    protected $appends = [];

    /**
     * The model's default values for attributes.
     *
     * @var array
     */
    protected $attributes = [];

    /**
     * Indicates if the model should be timestamped.
     *
     * @var bool
     */
    public $timestamps = true;

    /**
     * The primary key associated with the table.
     *
     * @var string
     */
    protected $primaryKey = 'code';

    /**
     * The data type of the auto-incrementing ID.
     *
     * @var string
     */
    protected $keyType = 'string';

    /**
     * The number of models to return for pagination.
     *
     * @var int
     */
    protected $perPage = 20;
}