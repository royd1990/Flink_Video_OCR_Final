package org.myorg.quickstart;

import com.esotericsoftware.kryo.Kryo;
import com.esotericsoftware.kryo.Serializer;
import com.esotericsoftware.kryo.io.Input;
import com.esotericsoftware.kryo.io.Output;
import org.bytedeco.javacpp.opencv_core;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;

import static org.bytedeco.javacpp.opencv_imgcodecs.imread;

/**
 * Created by royd1990 on 27/07/16.
 */
public class MatImageSerialize extends Serializer<opencv_core.Mat>{
    @Override
    public void write(Kryo kryo, Output output, opencv_core.Mat object) {
        int size = object.rows() * object.cols() * object.channels();
        byte[] image;
        image = new byte[size];
        object.getByteBuffer().get(image);
        output.write(image);

    }

    @Override
    public opencv_core.Mat read(Kryo kryo, Input input, Class<opencv_core.Mat> type) {
        // try {
        BufferedImage b = null;
        try {
            b = ImageIO.read(new File("Messi.jpeg"));
        } catch (IOException e) {
        }
        int length = input.read();
        byte[] inputData = new byte[length];
        int imType;
        //       OpenCVFrameConverter.ToMat converterToMat  = new OpenCVFrameConverter.ToMat();;
        input.read(inputData);
        InputStream in = new ByteArrayInputStream(inputData);
        BufferedImage img = null;
        try {
            img = ImageIO.read(in);        //   } catch (IOException e) {
        //     e.printStackTrace();
        //  }
        } catch (IOException e) {
            e.printStackTrace();
        }
        //imType=img.getType();
        //Mat image = new Mat(img.getHeight(),img.getWidth(), imType);
        //int x = globalImage.rows();
        //Mat image = new Mat(globalImage.rows(),globalImage.cols(),globalImage.type());
        // image=opencv_imgcodecs.imread("New.jpg");
        //        opencv_core.CV_8UC
        opencv_core.Mat image = new opencv_core.Mat();
        String filename = "Dump.jpg";
        image=imread(filename);

        if(!(image.empty())) {
            return image;
        }
        else{
            return image;
        }
    }
}
