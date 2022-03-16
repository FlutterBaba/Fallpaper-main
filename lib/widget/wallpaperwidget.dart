import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';
import '../models/photos_model.dart';
import '../view/image_view.dart';

class Wallpaper extends StatefulWidget {
  final List<PhotosModel> listPhotos;
  const Wallpaper({Key? key, required this.listPhotos}) : super(key: key);

  @override
  State<Wallpaper> createState() => _WallpaperState();
}

class _WallpaperState extends State<Wallpaper> {
  InterstitialAd? _interstitialAd;

  bool _isInterstitialAdReady = false;

  void loadInterstitialAd({required String imgPath}) {
    InterstitialAd.load(
      adUnitId:InterstitialAd.testAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageView(
                    imgPath: imgPath,
                  ),
                ),
              );
            },
          );

          _isInterstitialAdReady = true;
        },
        onAdFailedToLoad: (err) {
          print('Failed to load an interstitial ad: ${err.message}');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: StaggeredGridView.countBuilder(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        itemCount: widget.listPhotos.length,
        itemBuilder: (context, index) {
          PhotosModel photoModel = widget.listPhotos[index];
          return GridTile(
            child: GestureDetector(
              onTap: () {
                loadInterstitialAd(
                  imgPath: photoModel.src!.portrait!,
                );
                if (_isInterstitialAdReady) {
                  _interstitialAd?.show();
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImageView(
                        imgPath: photoModel.src!.portrait!,
                      ),
                    ),
                  );
                }
              },
              child: Hero(
                tag: photoModel.src!.portrait!,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: kIsWeb
                      ? Image.network(
                          photoModel.src!.portrait!,
                          height: 50,
                          width: 100,
                          fit: BoxFit.cover,
                        )
                      : CachedNetworkImage(
                          imageUrl: photoModel.src!.portrait!,
                          placeholder: (context, url) => Container(
                            color: const Color(0xfff5f8fd),
                          ),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
          );
        },
        staggeredTileBuilder: (index) {
          return StaggeredTile.count(1, index.isEven ? 1.2 : 1.8);
        },
      ),
    );
  }
}
