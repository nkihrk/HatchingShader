# Hatching Shader（ハッチングシェーダー）

ハッチングを表現したシェーダーです。このシェーダーにはTAM(Tonal Art Map)が必要です。サンプルとしてトーン風と鉛筆風のTAMを用意しておきました。  
Unity5.6.3p1(64bit)の環境で作成しました。

### 各シェーダーの使用用途

* HatchingShader……キャラクターなどでの使用を想定して調整しています。

* HatchingShaderLerpTes/HatchingShaderTes……背景のオブジェクトなどで使うことを想定し、上記のシェーダーに機能を追加したものです。機能に差はありませんが、二つのシェーダーで若干見た目に差があります。

![](https://nkihrk.github.io/img/works/shader/ugolino_with_hatching_shader.jpg)

---------------------------------------------------------------------------------  

### インスペクターのパラメーターについて  

* Hatch0～5……作成したTAM(Tonal Art Map)を貼り付けてください。

* Outline Mask Texture……削除する任意のアウトラインを指定します。黒背景を用意し、消したい箇所を白く塗りつぶしてください。  
※アウトラインを設定した状態でビルボードをオンにするとバグります。ビルボードを使用する場合はアウトラインの設定をオフにしてください。

* Outline Color……アウトラインの色を設定します。初期は下記のRim Power/Rim Amplitudeの影響を受けるように設定されています。

* Outline Width……アウトラインの幅を設定します。

* Toggle Billboard……オブジェクトをビルボード化します。(未調整なのでおいおい対応します)

* Threshold……ワールドライトの光の色による影響を閾値で制限します。  
解説：ワールドライトの色によってはオブジェクトが黒塗りになってしまう場合があります。これを防ぐためにライトの色RGBのスカラーを算出し、閾値よりも小さい場合ViewBasedに切り替えるようにコードを書いています。

* Angle……オブジェクトをY軸まわりで回転させます。

* _[X/Y/Z]comp……該当軸方向に圧縮します。

* Rim Power/Rim Amplitude……視線ベクトルで色が変異します。通常のRim効果と同じ感覚で設定すればいいです。（ただのおまけ）

* NdotL or NdotV……0に近いほどワールドのライトベクトルの影響を受けやすく、1に近いほど視線ベクトルの影響を受けやすいです。

* Density……影の濃淡を調整できます。

* Roughness……影の粗さを調整できます。

* Toggle Gray Scale……色をグレースケールにします。

* Cull Mode……Cullの設定ができます  


### [HatchingShaderLerpTes/HatchingShaderTes]で追加されたパラメーターについて  

* Noise Texture……テクスチャの色情報に沿って形が変形します。

* [Min/Max] Distance……テッセレーション（ポリゴンをGPUで増やす処理）によるポリゴンの増減をプレイヤーの距離によって制御します。  
※テッセレーションによってポリゴンを増やしすぎると、GPUの負荷が急激に上がります。それを軽減するために、[Min/Max] Distanceによって増やすポリゴンを段階的に制御します。

* Tessellation……オブジェクトのポリゴンを増やします。

* Noise Speed……Noise Textureを回転させる速度を設定します。

* Noise Power……Noise Textureによって頂点が押し出される度合いを設定します。

* Noise Factor……全体的な頂点の押し出しの度合いを調整します。  
※Noise Textureをセットしていない場合、Noise Powerは機能しません。しかし、Noise SpeedおよびNoise Factorに関しては機能します。  


### 最後に。  
コード自体の最適化、効率化は一切おこなっていない上に、[参考にした論文](http://hhoppe.com/hatching.pdf "Real-Time Hatching")通りにテクスチャを二枚にパックすることもしていません。コードの冗長さには目をつむってください。数列とかアルゴリズム考えるのめんどくさかった(´･_･`)
