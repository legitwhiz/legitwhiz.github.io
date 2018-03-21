/* =========================================================*/
// jquery.shideshow.js / ver.2.5

// Copyright (c) 2015 CoolWebWindow
// This code is released under the MIT License
// https://osdn.jp/projects/opensource/wiki/licenses%2FMIT_license

// Date: 2016-02-21
// Author: CoolWebWindow
// Mail: info@coolwebwindow.com
// Web: http://www.coolwebwindow.com

// Used jquery.js
// http://jquery.com/
/* =========================================================*/

$(function($){
    $.fn.slideshow = function(options) {
        // オプション
        var o = $.extend({
            touch        : true,
            touchDistance : '80',
            bgImage      : false,
            autoSlide    : true,
            effect       : 'fade',
            repeat       : true,
            easing       : 'liner',
            interval     : 3000,
            duration     : 1000,
            imgHoverStop : true,
            navHoverStop : true,
            navImg       : true,
            navImgCustom : true,
            navImgSuffix : ''
        }, options);

        // セレクター
        var $slider     = $(this),
            $container  = $slider.find('.slideInner'),
            $element    = $container.children(),
            $prevNav    = $slider.find('.slidePrev'),
            $nextNav    = $slider.find('.slideNext'),
            $controlNav = $slider.find('.controlNav');

        // カウンター初期化
        var current = 0;
        var next = 1;

        // PREV/NEXTフラグ
        var flag = 'nextElement';

        // ストップフラグ
        var stopFlag = false;

        // ホバーフラグ
        var hoverFlag = false;

        // スマホ判定
        var onClick = ('ontouchstart' in document) ? 'touchstart' : 'click';

        // 画像をbackground-imageにする
        if(o.bgImage) {
            // img要素を非表示にする
            $element.find('img').css('display' , 'none');

            // 画像パス取得・背景画像としてセット
            for (i=0; i < $element.length; i++) {
                var src = [];
                src[i] = $('img', $element[i]).attr('src');
                $($element[i]).css({'background-image':'url('+src[i]+')'});
            }
        }

        // 最初の要素だけ表示する
        $element.not(':first').css('display' , 'none');

        // 読み込み時
        $(window).on('load resize', function(){
            // 要素の高さを取得
            elementHeight();
            // ナビゲーションの位置を取得
            var nextNavPosition = ($($element[current]).height() - $nextNav.find('img').height()) / 2;
            $prevNav.css('top', nextNavPosition +'px');
            $nextNav.css('top', nextNavPosition +'px');
        });

        // 画像の高さ分、表示領域を確保
        var elementHeight = function(){
            $container.height($($element[current]).find('img').height());
            $element.height($($element[current]).find('img').height());
        };

        // 画像が一枚のときはスライドショーにしない
        if($element.length <= 1 ){
            $slider.css('padding-bottom' , '0');
            $prevNav.css('display' , 'none');
            $nextNav.css('display' , 'none');
            return false;
        }

        // 自動切り替えスタート
        var start;
        var startTimer = function () {
            start = setInterval(function(){change();}, o.interval);
        };

        // 自動切り替えストップ
        var stopTimer = function () {
             clearInterval(start);
        };

        // 繰り返しなしの場合PREVボタン非表示
        if (!o.repeat) {
            $prevNav.hide();
        }

        // 要素を切り替えるスクリプト
        var change = function(){
            // PREV/NEXTボタンデザイン
            if (!o.repeat) {
                if(next > 0){
                    $prevNav.fadeIn('slow');
                }else{
                    $prevNav.fadeOut('slow');
                }
            }

            // コントールナビデザイン
            $controlNav.children('span').removeClass('current');
            $controlNav.children('span:eq(' + next + ')').addClass('current');

            // フェードしながら切り替える場合
            if (o.effect == 'fade') {
                $($element[current]).not(':animated').fadeOut(o.duration);
                $($element[next]).not(':animated').fadeIn(o.duration);

            // スライドしながら切り替える場合
            } else if  (o.effect == 'slide') {
                var elementWidth = $element.width();
                $element.css('display', 'block');
                if(flag == 'prevElement') {
                    $element.css('left', - elementWidth +'px');
                    $($element[current]).css('left', 0 +'px');
                    $($element[current]).not(':animated').animate({'left': '+=' + elementWidth +'px'}, o.duration, o.easing);
                    $($element[next]).not(':animated').animate({'left': '+=' + elementWidth +'px'}, o.duration, o.easing);
                }
                if(flag == 'nextElement') {
                    $element.css('left', elementWidth +'px');
                    $($element[current]).css('left', 0 +'px');
                    $($element[current]).not(':animated').animate({'left': '-=' + elementWidth +'px'}, o.duration, o.easing);
                    $($element[next]).not(':animated').animate({'left': '-=' + elementWidth +'px'}, o.duration, o.easing);
                }
            }

            // リピートする場合
            if (o.repeat) {
                if ((next + 1) < $element.length) {
                     current = next;
                     next++;
                } else {
                     current = $element.length - 1;
                     next = 0;
                }
            }

            // 最後の要素でストップする場合
            if (!o.repeat) {
                if ((next + 1) < $element.length) {
                    current = next;
                    next++;
                    $nextNav.fadeIn();
                } else {
                    current = $element.length - 1;
                    next = 0;
                    stopTimer();
                    $nextNav.fadeOut();
                    stopFlag = true;
              }
            }
        };

        // PREVボタン
        var prevSlide = function () {
            flag = 'prevElement';
            if(current == 0) {
                next = $element.length - 1;
            }else {
                next = current -1;
            }
            stopTimer();
            change();
            if(!stopFlag && o.autoSlide && !hoverFlag) {
                startTimer();
            }
            flag = 'nextElement';
        }

        // NEXTボタン
        var nextSlide = function () {
            flag = 'nextElement';
            stopTimer();
            change();
            if(!stopFlag && o.autoSlide && !hoverFlag) {
                startTimer();
            }

        }

        // PREVスライド
        $prevNav.on(onClick,function() {
            if($element.is(':animated')) {
                return false;
            }
            prevSlide();
        });

        // NEXTスライド
        $nextNav.on(onClick,function() {
            if($element.is(':animated')) {
                return false;
            }
            nextSlide();
        });

        // ナビゲーションの生成
        $element.each(function (e) {
            $('<span/>').text(e + 1).appendTo($controlNav).on('click',function() {
                if($element.is(':animated')) {
                    return false;
                }
                if(e < current) {
                    flag='prevElement';
                } else if(e > current) {
                    flag='nextElement';
                }
                if(e != current) {
                    if(e == $element.length) {
                        next = 0;
                    }else {
                        next = e;
                    }
                    stopTimer();
                    change();
                    if(!stopFlag && o.autoSlide && !hoverFlag) {
                        startTimer();
                    }
                    flag = 'nextElement';
                }
            });
        });
        $controlNav.find('span:first-child').addClass('current');

        // ナビゲーションの画像化
        if(o.navImg){
            $element.each(function (e) {
                var cloneEle = $($element.find('img')[e]).clone();
                $($controlNav.find('span')[e]).html(cloneEle);
                // サムネイル用の画像がある場合
                if(o.navImgCustom && !(o.navImgSuffix == '')){
                    // 画像名を取得
                    var src = cloneEle.attr('src');
                    // サムネイル用の画像名を取得（接尾辞を付加）
                    var srcSuffix = src.replace(/^(.+)(\.[a-z]+)$/, '$1' + o.navImgSuffix + '$2');
                    $($controlNav.find('img')[e]).attr('src', srcSuffix);
                }
            });
        }

        // タッチパネルはホバー動作無効
        if(!('ontouchstart' in document)) {
            // 画像にホバーした際の動作
            if(o.imgHoverStop){
                $container.hover(function() {
                    stopTimer();
                },function() {
                    if(!stopFlag && o.autoSlide) {
                        startTimer();
                    }
                });
            }

            // ナビゲーションにホバーした際の動作
            if(o.navHoverStop){
                $prevNav.hover(function() {
                    hoverFlag = true;
                    stopTimer();
                },function() {
                    hoverFlag = false;
                    if(!stopFlag && o.autoSlide) {
                        startTimer();
                    }
                });

                $nextNav.hover(function() {
                    hoverFlag = true;
                    stopTimer();
                },function() {
                    hoverFlag = false;
                    if(!stopFlag && o.autoSlide) {
                        startTimer();
                    }
                });

                $controlNav.hover(function() {
                    stopTimer();
                    hoverFlag = true;
                },function() {
                    hoverFlag = false;
                    if(!stopFlag && o.autoSlide) {
                        startTimer();
                    }
                });
            }
        }

        if(o.touch) {
            // タッチパネル対応
            $element.on('touchstart', touchStart);
            $element.on('touchmove' , touchMove);
            $element.on('touchend' , touchEnd);
        }

        // タップした位置をメモリーする
        function touchStart(e) {
            var pos = Position(e);
            $element.data('memoryS',pos.x);

        }

        // タップを離した位置をメモリーする
        function touchMove(e) {
            // 位置情報を取得
            var pos = Position(e);
            $element.data('memoryE',pos.x);
        }

        // スワイプ（タップした位置からプラスかマイナスかで左右移動を判断）
        function touchEnd(e) {
            var startX = $element.data('memoryS');
            var endX = $element.data('memoryE');

            // 左から右へスワイプ
            if(startX < endX) {
                if(endX - startX > o.touchDistance){
                    if($element.is(':animated')) {
                        return false;
                    }
                    prevSlide();
                }

            // 右から左へスワイプ
            }else{
                if(startX - endX > o.touchDistance){
                    if($element.is(':animated')) {
                        return false;
                    }
                    nextSlide();
                }
            }
        }

        // 現在位置を取得
        function Position(e){
            var x = Math.floor(e.originalEvent.touches[0].pageX)
            var y = Math.floor(e.originalEvent.touches[0].pageY);
            var pos = {'x':x , 'y':y};
            return pos;
        }

        // 自動スタート設定
        if(o.autoSlide){
            startTimer();
        }

    };
});
