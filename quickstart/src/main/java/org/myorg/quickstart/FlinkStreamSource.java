package org.myorg.quickstart;

import org.apache.flink.configuration.Configuration;
import org.apache.flink.streaming.api.functions.source.RichSourceFunction;
import org.apache.flink.streaming.api.functions.source.SourceFunction;
import org.bytedeco.javacpp.opencv_core;
import java.io.IOException;
import static org.bytedeco.javacpp.opencv_imgcodecs.imwrite;
import static org.bytedeco.javacpp.opencv_imgproc.COLOR_BGR2GRAY;
import static org.bytedeco.javacpp.opencv_imgproc.cvtColor;
import static org.bytedeco.javacpp.opencv_imgproc.equalizeHist;
import org.bytedeco.javacv.*;

/**
 * Created by royd1990 on 27/07/16.
 */
public class FlinkStreamSource extends RichSourceFunction<opencv_core.Mat> {
    String videoFileName = "/home/royd1990/Downloads/20160616_144027.mp4"; //Changed for Grid 5K
    private transient volatile boolean running = true;
    private OpenCVFrameConverter.ToMat converterToMat;

    private void init() throws IOException {
        converterToMat = new OpenCVFrameConverter.ToMat();
    }

    @Override
    public void run(SourceFunction.SourceContext<opencv_core.Mat> ctx) throws Exception {
        FFmpegFrameGrabber grabber = new FFmpegFrameGrabber(videoFileName);
        // CanvasFrame framer = new CanvasFrasme("Face Time", CanvasFrame.getDefaultGamma() / grabber.getGamma());

        try {
            grabber.start();
            opencv_core.Mat videoMat = new opencv_core.Mat();
            System.out.println("Entered Source Function");
            while (running) {
                Frame videoFrame = grabber.grab();
                if (videoFrame == null || videoFrame.image == null) continue;
                videoMat = converterToMat.convert(videoFrame);
                opencv_core.Mat videoMatGray = new opencv_core.Mat();
                cvtColor(videoMat, videoMatGray, COLOR_BGR2GRAY);
                equalizeHist(videoMatGray, videoMatGray);
                //    framer.showImage(videoFrame);
                String filename= "Dump.jpg";
                imwrite(filename,videoMatGray);
                ctx.collect(videoMatGray);
                videoMatGray.release();
            }
            videoMat.release();

        } catch (FrameGrabber.Exception e) {
            running = false;
            e.printStackTrace();
        }

    }

    public void open(Configuration parameters) throws Exception {
        super.open(parameters);
        running = true;
        init();
    }

    @Override
    public void cancel() {
            running=false;

    }

}
