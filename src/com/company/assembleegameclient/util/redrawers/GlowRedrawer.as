package com.company.assembleegameclient.util.redrawers {
import com.company.assembleegameclient.parameters.Parameters;
import com.company.util.PointUtil;

import flash.display.BitmapData;
import flash.utils.Dictionary;

public class GlowRedrawer {

    private static const GRADIENT_MAX_SUB:uint = 0x282828;
    private static var glowHashes:Dictionary = new Dictionary();


    public static function outlineGlow(_arg_1:BitmapData, _arg_2:uint, _arg_3:Number = 1.4, _arg_4:Boolean = false):BitmapData {
        var _local_5:String = getHash(_arg_2, _arg_3);
        if (((_arg_4) && (isCached(_arg_1, _local_5)))) {
            return (glowHashes[_arg_1][_local_5]);
        }
        var sprite:BitmapData = new BitmapData(_arg_1.width, _arg_1.height, true, 0);
        sprite.copyPixels(_arg_1, _arg_1.rect, PointUtil.ORIGIN, null, null, true);
        shadeBottom(sprite);
        var outline:BitmapData = softGlow(sprite, Math.max(1, Math.round(_arg_3)));
        tint(outline, 0, 1);
        var result:BitmapData;
        if (_arg_2 != 0xFFFFFFFF) {
            var glowRadius:int = (((Parameters.isGpuRender()) && (!((_arg_2 == 0)))) ? 8 : 6);
            var glowAlpha:Number = (((Parameters.isGpuRender()) && (!((_arg_2 == 0)))) ? 0.5 : 0.3);
            result = softGlow(sprite, glowRadius);
            tint(result, _arg_2, glowAlpha);
            result.copyPixels(outline, outline.rect, PointUtil.ORIGIN, null, null, true);
        }
        else {
            result = outline;
        }
        result.copyPixels(sprite, sprite.rect, PointUtil.ORIGIN, null, null, true);
        if (_arg_4) {
            cache(_arg_1, _arg_2, _arg_3, result);
        }
        return (result);
    }

    public static function addGlow(_arg_1:BitmapData, _arg_2:uint, _arg_3:int, _arg_4:Number):BitmapData {
        var _local_5:BitmapData = softGlow(_arg_1, _arg_3);
        tint(_local_5, _arg_2, _arg_4);
        _local_5.copyPixels(_arg_1, _arg_1.rect, PointUtil.ORIGIN, null, null, true);
        return (_local_5);
    }

    private static function shadeBottom(_arg_1:BitmapData):void {
        var _local_3:int = (_arg_1.height - 1);
        var _local_4:int = (GRADIENT_MAX_SUB & 0xFF);
        var _local_2:int = 0;
        while (_local_2 < _arg_1.height) {
            var _local_5:int = int(((_local_2 / _local_3) * _local_4));
            var _local_6:int = 0;
            while (_local_6 < _arg_1.width) {
                var _local_7:uint = _arg_1.getPixel32(_local_6, _local_2);
                var _local_8:int = ((_local_7 >>> 24) & 0xFF);
                if (_local_8 != 0) {
                    var _local_9:int = Math.max(0, (((_local_7 >> 16) & 0xFF) - _local_5));
                    var _local_10:int = Math.max(0, (((_local_7 >> 8) & 0xFF) - _local_5));
                    var _local_11:int = Math.max(0, ((_local_7 & 0xFF) - _local_5));
                    _arg_1.setPixel32(_local_6, _local_2, ((_local_8 << 24) | (_local_9 << 16) | (_local_10 << 8) | _local_11));
                }
                _local_6++;
            }
            _local_2++;
        }
    }

    private static function softGlow(_arg_1:BitmapData, _arg_2:int):BitmapData {
        var _local_3:int = _arg_1.width;
        var _local_4:int = _arg_1.height;
        var _local_5:int = (_arg_2 * 2) + 1;
        var _local_6:int = _local_3 * _local_4;
        var _local_12:Vector.<int> = new Vector.<int>(_local_6, true);
        var _local_13:Vector.<int> = new Vector.<int>(_local_6, true);
        var _local_7:int = 0;
        while (_local_7 < _local_4) {
            var _local_8:int = (_local_7 * _local_3);
            var _local_9:int = 0;
            while (_local_9 < _local_3) {
                _local_12[(_local_8 + _local_9)] = ((_arg_1.getPixel32(_local_9, _local_7) >>> 24) & 0xFF);
                _local_9++;
            }
            _local_7++;
        }
        _local_7 = 0;
        while (_local_7 < _local_4) {
            _local_8 = (_local_7 * _local_3);
            var _local_10:int = 0;
            _local_9 = 0;
            var _local_11:int = -_arg_2;
            while (_local_11 <= _arg_2) {
                var _local_15:int = _local_11;
                if (_local_15 < 0) {
                    _local_15 = 0;
                }
                else {
                    if (_local_15 >= _local_3) {
                        _local_15 = (_local_3 - 1);
                    }
                }
                _local_9 = (_local_9 + _local_12[(_local_8 + _local_15)]);
                _local_11++;
            }
            while (_local_10 < _local_3) {
                _local_13[(_local_8 + _local_10)] = (_local_9 / _local_5);
                var _local_16:int = (_local_10 + _arg_2 + 1);
                if (_local_16 >= _local_3) {
                    _local_16 = (_local_3 - 1);
                }
                var _local_17:int = (_local_10 - _arg_2);
                if (_local_17 < 0) {
                    _local_17 = 0;
                }
                _local_9 = (_local_9 + _local_12[(_local_8 + _local_16)]) - _local_12[(_local_8 + _local_17)];
                _local_10++;
            }
            _local_7++;
        }
        var _local_14:BitmapData = new BitmapData(_local_3, _local_4, true, 0);
        _local_7 = 0;
        while (_local_7 < _local_3) {
            _local_9 = 0;
            _local_11 = -_arg_2;
            while (_local_11 <= _arg_2) {
                _local_15 = _local_11;
                if (_local_15 < 0) {
                    _local_15 = 0;
                }
                else {
                    if (_local_15 >= _local_4) {
                        _local_15 = (_local_4 - 1);
                    }
                }
                _local_9 = (_local_9 + _local_13[(_local_15 * _local_3) + _local_7]);
                _local_11++;
            }
            var _local_18:int = 0;
            while (_local_18 < _local_4) {
                var _local_19:int = (_local_18 * _local_3) + _local_7;
                _local_14.setPixel32(_local_7, _local_18, ((_local_9 / _local_5) << 24));
                _local_16 = (_local_18 + _arg_2 + 1);
                if (_local_16 >= _local_4) {
                    _local_16 = (_local_4 - 1);
                }
                _local_17 = (_local_18 - _arg_2);
                if (_local_17 < 0) {
                    _local_17 = 0;
                }
                _local_9 = (_local_9 + _local_13[(_local_16 * _local_3) + _local_7]) - _local_13[(_local_17 * _local_3) + _local_7];
                _local_18++;
            }
            _local_7++;
        }
        return (_local_14);
    }

    private static function tint(_arg_1:BitmapData, _arg_2:uint, _arg_3:Number):void {
        var _local_4:uint = _arg_2 & 0xFFFFFF;
        var _local_5:int = 0;
        while (_local_5 < _arg_1.height) {
            var _local_6:int = 0;
            while (_local_6 < _arg_1.width) {
                var _local_7:uint = _arg_1.getPixel32(_local_6, _local_5);
                var _local_8:int = ((_local_7 >>> 24) & 0xFF);
                if (_local_8 != 0) {
                    _arg_1.setPixel32(_local_6, _local_5, ((int((_local_8 * _arg_3)) << 24) | _local_4));
                }
                _local_6++;
            }
            _local_5++;
        }
    }

    private static function cache(_arg_1:BitmapData, _arg_2:uint, _arg_3:Number, _arg_4:BitmapData):void {
        var _local_6:Object;
        var _local_5:String = getHash(_arg_2, _arg_3);
        if ((_arg_1 in glowHashes)) {
            glowHashes[_arg_1][_local_5] = _arg_4;
        }
        else {
            _local_6 = {};
            _local_6[_local_5] = _arg_4;
            glowHashes[_arg_1] = _local_6;
        }
    }

    private static function isCached(_arg_1:BitmapData, _arg_2:String):Boolean {
        var _local_3:Object;
        if ((_arg_1 in glowHashes)) {
            _local_3 = glowHashes[_arg_1];
            if ((_arg_2 in _local_3)) {
                return (true);
            }
        }
        return (false);
    }

    private static function getHash(_arg_1:uint, _arg_2:Number):String {
        return ((int((_arg_2 * 10)).toString() + _arg_1));
    }


}
}//package com.company.assembleegameclient.util.redrawers