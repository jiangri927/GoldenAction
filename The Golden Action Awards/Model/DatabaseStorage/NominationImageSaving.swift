//
//  NominationImageSaving.swift
//  The Golden Action Awards
//
//  Created by Michael Kunchal on 6/22/18.
//  Copyright © 2018 Michael Kunchal. All rights reserved.
//

import Foundation
import Firebase


extension Nominations {
    // MARK: - Save Array of Images!
    class func saveNomPics(nomPics: [UIImage], completion: @escaping ([String]) -> Void) {
        if nomPics.count >= 6 {
            let pic = ImageSaving(image: nomPics[0])
            let picTwo = ImageSaving(image: nomPics[1])
            let picThree = ImageSaving(image: nomPics[2])
            let picFour = ImageSaving(image: nomPics[3])
            let picFive = ImageSaving(image: nomPics[4])
            let picSix = ImageSaving(image: nomPics[5])
            var urls = [String]()
            pic.saveNomPic { (error, metaOne) in
                let test = metaOne!.customMetadata
                print(test)
                /*if let urlOne = metaOne?.downloadURL()?.absoluteString {
                    urls.append(urlOne)
                } */
               /* picTwo.saveNomPic(completion: { (error, metaTwo) in
                    if let urlTwo = metaTwo?.downloadURL()?.absoluteString {
                        urls.append(urlTwo)
                    }
                    picThree.saveNomPic(completion: { (error, metaThree) in
                        if let urlThree = metaThree?.downloadURL()?.absoluteString {
                            urls.append(urlThree)
                        }
                        picFour.saveNomPic(completion: { (error, metaFour) in
                            if let urlFour = metaFour?.downloadURL()?.absoluteString {
                                urls.append(urlFour)
                            }
                            picFive.saveNomPic(completion: { (error, metaFive) in
                                if let urlFive = metaFive?.downloadURL()?.absoluteString {
                                    urls.append(urlFive)
                                }
                                picSix.saveNomPic(completion: { (error, metaSix) in
                                    if let urlSix = metaSix?.downloadURL()?.absoluteString {
                                        urls.append(urlSix)
                                    }
                                    if urls.count != 0 {
                                        completion(urls)
                                    } else {
                                        completion([])
                                    }
                                })
                            })
                        })
                    })
                }) */
            }
        } else if nomPics.count == 5 {
            let pic = ImageSaving(image: nomPics[0])
            let picTwo = ImageSaving(image: nomPics[1])
            let picThree = ImageSaving(image: nomPics[2])
            let picFour = ImageSaving(image: nomPics[3])
            let picFive = ImageSaving(image: nomPics[4])
            var urls = [String]()
            pic.saveNomPic { (error, metaOne) in
                if let urlOne = metaOne?.path {
                    urls.append(urlOne)
                }
                picTwo.saveNomPic(completion: { (error, metaTwo) in
                    if let urlTwo = metaTwo?.path {
                        urls.append(urlTwo)
                    }
                    picThree.saveNomPic(completion: { (error, metaThree) in
                        if let urlThree = metaThree?.path {
                            urls.append(urlThree)
                        }
                        picFour.saveNomPic(completion: { (error, metaFour) in
                            if let urlFour = metaFour?.path {
                                urls.append(urlFour)
                            }
                            picFive.saveNomPic(completion: { (error, metaFive) in
                                if let urlFive = metaFive?.path {
                                    urls.append(urlFive)
                                }
                                if urls.count != 0 {
                                    completion(urls)
                                } else {
                                    completion([])
                                }
                            })
                        })
                    })
                })
            }
        } else if nomPics.count == 4 {
            let pic = ImageSaving(image: nomPics[0])
            let picTwo = ImageSaving(image: nomPics[1])
            let picThree = ImageSaving(image: nomPics[2])
            let picFour = ImageSaving(image: nomPics[3])
            var urls = [String]()
            pic.saveNomPic { (error, metaOne) in
                if let urlOne = metaOne?.path {
                    urls.append(urlOne)
                }
                picTwo.saveNomPic(completion: { (error, metaTwo) in
                    if let urlTwo = metaTwo?.path {
                        urls.append(urlTwo)
                    }
                    picThree.saveNomPic(completion: { (error, metaThree) in
                        if let urlThree = metaThree?.path{
                            urls.append(urlThree)
                        }
                        picFour.saveNomPic(completion: { (error, metaFour) in
                            if let urlFour = metaFour?.path {
                                urls.append(urlFour)
                            }
                            if urls.count != 0 {
                                completion(urls)
                            } else {
                                completion([])
                            }
                        })
                    })
                })
            }
        } else if nomPics.count == 3 {
            let pic = ImageSaving(image: nomPics[0])
            let picTwo = ImageSaving(image: nomPics[1])
            let picThree = ImageSaving(image: nomPics[2])
            var urls = [String]()
            pic.saveNomPic { (error, metaOne) in
                if let urlOne = metaOne?.path {
                    urls.append(urlOne)
                }
                picTwo.saveNomPic(completion: { (error, metaTwo) in
                    if let urlTwo = metaTwo?.path {
                        urls.append(urlTwo)
                    }
                    picThree.saveNomPic(completion: { (error, metaThree) in
                        if let urlThree = metaThree?.path {
                            urls.append(urlThree)
                        }
                        if urls.count != 0 {
                            completion(urls)
                        } else {
                            completion([])
                        }
                    })
                })
            }
        } else if nomPics.count == 2 {
            let pic = ImageSaving(image: nomPics[0])
            let picTwo = ImageSaving(image: nomPics[1])
            var urls = [String]()
            pic.saveNomPic { (error, metaOne) in
                if let urlOne = metaOne?.path {
                    urls.append(urlOne)
                }
                picTwo.saveNomPic(completion: { (error, metaTwo) in
                    if let urlTwo = metaTwo?.path {
                        urls.append(urlTwo)
                    }
                    if urls.count != 0 {
                        completion(urls)
                    } else {
                        completion([])
                    }
                })
            }
        } else if nomPics.count == 1 {
            let pic = ImageSaving(image: nomPics[0])
            var urls = [String]()
            pic.saveNomPic { (error, metaOne) in
                if let urlOne = metaOne?.path {
                    urls.append(urlOne)
                    completion(urls)
                } else {
                    completion([])
                }
            }
        } else {
            completion([])
        }
    }
    
}
