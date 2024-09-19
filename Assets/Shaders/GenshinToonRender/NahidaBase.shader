Shader "Unlit/NahidaBase"
{
    Properties
    {
        _AmbientColor ("Ambient Color", Color) = (0.667,0.667,0.667,1) //环境光颜色
        _DiffuseColor ("Diffuse Color", Color) = (0.906,0.906,0.906,1) //漫反射颜色
        _ShadowColor ("Shadow Color", Color) = (0.737,0.737,0.737,1) //阴影颜色
        
        _BaseTexFac ("Base Tex Fac", Range(0,1)) = 1 //基础纹理强度
        _BaseTex ("Base Tex", 2D) = "white" {} //基础纹理
        _ToonTexFac ("Toon Tex Fac", Range(0,1)) = 1 //卡通纹理强度
        _ToonTex ("Toon Tex", 2D) = "white" {} //卡通纹理  
        _SphereTexFac ("Sphere Tex Fac", Range(0,1)) = 0 //球面纹理强度
        _SphereTex ("Sphere Tex", 2D) = "white" {} //球面纹理
        _SphereMulAdd ("Sphere Mul/ADD", Range(0,1)) = 0//球面纹理乘/加
        
        _DoubleSided ("Double Sided", Range(0,1)) = 0 //双面渲染
        _Alpha ("Alpha", Range(0,1)) = 1 //透明度
        
        _MetalTex ("Metal Tex", 2D) = "black" {} //金属纹理
        
        _SpecExpon ("Specular Exponent", Range(1,128)) = 50 //高光指数
        _KsNonMetallic ("Ks Non-Metallic", Range(0,3)) = 1 //非金属高光强度
        _ksMetallic ("Ks Metallic", Range(0,3)) = 1 //金属高光强度
        
        _NormalMap ("Normal Map", 2D) = "bump" {} //法线纹理
        _ILM ("ILM", 2D) = "black" {} //ILM纹理
        
        _RampTex ("Ramp Tex", 2D) = "white" {} //渐变纹理
        
        _RampMapRow0 ("Ramp Map Row 0", Range(0,5)) = 1 //渐变纹理行0
        _RampMapRow1 ("Ramp Map Row 1", Range(0,5)) = 4 //渐变纹理行1
        _RampMapRow2 ("Ramp Map Row 2", Range(0,5)) = 3 //渐变纹理行2
        _RampMapRow3 ("Ramp Map Row 3", Range(0,5)) = 5 //渐变纹理行3
        _RampMapRow4 ("Ramp Map Row 4", Range(0,5)) = 2 //渐变纹理行4
        
        _OutlineOffset ("Outline Offset", Float) = 0.000015 //轮廓偏移
        
        _OutlineMapColor0 ("Outline Map Color 0", Color) = (0,0,0,0) //轮廓颜色0
        _OutlineMapColor1 ("Outline Map Color 1", Color) = (0,0,0,0) //轮廓颜色1
        _OutlineMapColor2 ("Outline Map Color 2", Color) = (0,0,0,0) //轮廓颜色2
        _OutlineMapColor3 ("Outline Map Color 3", Color) = (0,0,0,0) //轮廓颜色3
        _OutlineMapColor4 ("Outline Map Color 4", Color) = (0,0,0,0) //轮廓颜色4
    }
    SubShader
    {
        LOD 100 //LOD级别
        
        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode"="ShadowCaster"} //阴影投射
            
            ZWrite On //深度写入
            ZTest LEqual //深度测试
            ColorMask 0    //颜色掩码
            Cull Off //剔除模式
            
            HLSLPROGRAM
                #pragma exclude_renderers gles gles3 glcore //排除渲染器
                #pragma target 4.5 //目标版本

            //-----------------------------------------------------------------------------
            //Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON //透明度测试
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A //平滑度纹理-反照率通道A

            //-----------------------------------------------------------------------------
            //GPU Instancing
            #pragma multi_compile_instancing //GPU实例化
            #pragma multi_compile _ DOTS_INSTANCING_ON //点实例化

            //-----------------------------------------------------------------------------
            // Universal Pipeline Keywords

            // This is used during shadow map generation to differentiate between punctual and non-punctual lights shadows, as they use different formulas to apply Normal Bias
            // 区分准时和非准时灯光阴影
            #pragma multi_compile_vertex_ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #pragma vertex ShadowPassVertex //阴影投射顶点着色器
            #pragma fragment ShadowPassFragment //阴影投射片段着色器

            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl" //输入.hlsl
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl" //阴影投射.hlsl
            ENDHLSL
        }
        
        Pass
        {
            Name "DepthNormals" //深度法线
            Tags{"LightMode" = "DepthNormals"} //渲染类型 
            
            ZWrite On //深度写入
            Cull Off //剔除模式
            
            HLSLPROGRAM
            
                #pragma exclude_renderers gles gles3 glcore //排除渲染器
                #pragma target 4.5 //目标版本

                #pragma vertex DepthNormalsVertex //深度法线顶点着色器
                #pragma fragment DepthNormalsFragment //深度法线片段着色器

                //-----------------------------------------------------------------------------
                // Material Keywords
                #pragma shader_feature_local _NORMALMAP //法线贴图
                #pragma shader_feature_local _PARALLAXMAP //视差贴图
                #pragma shader_feature_local _ _DETAIL_MULX2 _DETAIL_SCALED //细节
                #pragma shader_feature_local_fragment _ALPHATEST_ON //透明度测试
                #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A //平滑度纹理-反照率通道A

                //-----------------------------------------------------------------------------
                // GPU Instancing
                #pragma multi_compile_instancing //GPU实例化
                #pragma multi_compile _ DOTS_INSTANCING_ON //点实例化
    
                #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl" //输入.hlsl
                #include "Packages/com.unity.render-pipelines.universal/Shaders/LitDepthNormalsPass.hlsl" //深度法线.hlsl
            
            ENDHLSL
        }
        
        Pass
        {
            Name "DrawObject"
            Tags{"RenderPipeline" = "UniversalRenderPipeline" //渲染管线 
                "RenderType" = "Opaque" //渲染类型
                "LightMode" = "UniversalForward"} //通用前向渲染
            
            Cull Off
            
            HLSLPROGRAM
            #pragma multi_compile _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _SHADOWS_SOFT

            
            #pragma vertex vert
            #pragma fragment frag
            //make fog work
            #pragma multi_compile_fog //雾

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl" //核心.hlsl
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl" //光照.hlsl
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl" //声明深度纹理.hlsl
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl" //阴影.hlsl

            struct appdata //应用数据
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                half4 color : COLOR;
            };

            struct v2f //顶点结构
            {
                float2 uv : TEXCOORD0; //纹理坐标
                float3 positionWS : TEXCOORD1; //世界空间位置
                float3 positionVS : TEXCOORD2; //视图空间位置
                float4 positionCS : SV_POSITION; //裁剪空间位置
                float4 positionNDC : TEXCOORD3; //NDC空间位置
                float3 normalWS : TEXCOORD4; //世界空间法线
                float3 tangentWS : TEXCOORD5; //世界空间切线
                float3 bitangentWS : TEXCOORD6; //世界空间副切线
                float4 fogCoord : TEXCOORD7; //雾坐标
                float4 shadowCoord : TEXCOORD8; //阴影坐标
            };

            CBUFFER_START(UnityPerMaterial) //材质缓冲区
            float4 _AmbientColor; //环境光颜色
            float4 _DiffuseColor; //漫反射颜色
            float4 _ShadowColor; //阴影颜色

            half _BaseTexFac; //基础纹理系数
            sampler2D _BaseTex; //基础纹理
            sampler2D _SkinTex; //皮肤纹理
            float4 _BaseTex_ST; //基础纹理ST
            half _ToonTexFac; //卡通纹理系数
            sampler2D _ToonTex; //卡通纹理
            half _SphereTexFac; //球面纹理系数
            sampler2D _SphereTex; //球面纹理
            half _SphereMulAdd;//球面纹理乘加

            half _DoubleSided; //双面
            half _Alpha;//透明度

            sampler2D _MetalTex; //金属纹理
            float _SpecExpon;
            float _KsNonMetallic; //非金属Ks
            float _KsMetallic; //金属Ks

            sampler2D _NormalMap; //法线纹理
            sampler2D _ILM; //ILM纹理

            sampler2D _RampTex; //渐变纹理

            float _RampMapRow0; //渐变纹理行0
            float _RampMapRow1; //渐变纹理行1
            float _RampMapRow2; //渐变纹理行2
            float _RampMapRow3; //渐变纹理行3
            float _RampMapRow4; //渐变纹理行4

            CBUFFER_END //材质缓冲区结束

            v2f vert(appdata v) //顶点着色器
            {
                v2f o; //输出结构
                VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz); //获取顶点位置
                o.uv = TRANSFORM_TEX(v.uv, _BaseTex); //计算基础纹理坐标
                o.positionWS = vertexInput.positionWS; //世界空间位置
                o.positionVS = vertexInput.positionVS; //视图空间位置
                o.positionCS = vertexInput.positionCS; //裁剪空间位置
                o.positionNDC = vertexInput.positionNDC; //NDC空间位置

                VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(v.normal, v.tangent); //获取顶点法线
                o.tangentWS = vertexNormalInput.tangentWS; //世界空间切线
                o.bitangentWS = vertexNormalInput.bitangentWS; //世界空间副切线
                o.normalWS = vertexNormalInput.normalWS; //世界空间法线

                o.fogCoord = ComputeFogFactor(vertexInput.positionCS.z); //计算雾坐标

                o.shadowCoord = TransformWorldToShadowCoord(vertexInput.positionWS); //计算阴影坐标
                return o;
            }

            float4 frag(v2f i, bool IsFacing : SV_IsFrontFace) : SV_Target  //片段着色器
            {
                Light light = GetMainLight(i.shadowCoord); //获取主光源
                //PBR
                // float NoL = dot(normalize(i.normalWS), normalize(light.direction)); //法线与光照方向点积
                // float lambert = max(0, NoL); //Lambert
                // float halfLambert = pow(lambert * 0.5 + 0.5, 2); //半Lambert
                //
                // float4 baseTex = tex2D(_BaseTex, i.uv); //基础纹理
                //
                // float3 albedo = baseTex.rgb * halfLambert; //基础纹理颜色
                // float alpha = baseTex.a * _Alpha; //透明度
                //
                // float4 col = float4(albedo, alpha); //颜色
                // clip(col.a - 0.5); //裁剪
                // //apply fog
                // col.rgb = MixFog(col.rgb, i.fogCoord); //雾效

                //NPR
                float4 normalMap = tex2D(_NormalMap, i.uv); //法线纹理
                float3 normalTS = float3(normalMap.ag * 2 - 1, 0); //法线纹理
                normalTS.z = sqrt(1 - dot(normalTS.xy, normalTS.xy)); //法线纹理Z分量

                float3 N = normalize(mul(normalTS, float3x3(i.tangentWS,i.bitangentWS,i.normalWS)) ); //世界空间法线
                float3 V = normalize(mul((float3x3)UNITY_MATRIX_I_V, i.positionVS * (-1))); //视图空间法线（逆矩阵）
                float3 L = normalize(light.direction); //光照方向
                float3 H = normalize(L + V); //半角向量

                float NoL = dot(N, L); //法线与光照方向点积
                float NoH = dot(N, H); //法线与半角向量点积
                float NOV = dot(N, V); //法线与视图方向点积
                

                float3 normalVS = normalize(mul((float3x3)UNITY_MATRIX_V,N));//视图空间法线
                float2 matcapUV = normalVS.xy * 0.5 + 0.5; //matcapUV
                
                float4 baseTex = tex2D(_BaseTex, i.uv); //基础纹理

                
                return float4(tex2D(_ToonTex,matcapUV).rgb, 1);
                

                
            }
            ENDHLSL


        }
    }
}
