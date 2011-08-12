# Program: album_page.rb
# Author: Michael J. Sepcot - michael (dot) sepcot (at) gmail (dot) com
# Purpose: Tool to generate examples of what the Timothy Whaley and Associates, Artist Album mat pages would look like with actual pictures in them.

require 'rubygems'
require 'RMagick'

class ImageSize
  attr_accessor :width, :height
  
  def initialize( width, height )
    @width = width
    @height = height
  end
end

class ImageOffset
  attr_accessor :top, :left
  
  def initialize( left, top )
    @left = left
    @top = top
  end
end

class PageLayout
  attr_reader :type
  attr :photos
  
  def initialize( type )
    @type = type.to_s
    @photos = []
  end
  
  def add_photo( name, size = ImageSize.new( 240, 336 ), offset = ImageOffset.new( 0, 0 ), rotate = 0, code = '' )
    @photos << { :name => name, :size => size, :offset => offset, :rotate => rotate, :code => code }
  end
  
  def to_s
    contents = "#{@type}:"
    @photos.each do |photo|
      contents += ' ' + photo[:name].split('.')[0]
      contents += "(#{photo[:code]})" unless photo[:code].empty?
    end
    contents
  end
  
  def create( caption_text = nil )
    dst = Magick::Image.new( 960, 1440 ) { self.background_color = 'black' }
    
    @photos.each do |photo|
      src = Magick::Image.read( photo[:name] ).first
      src.background_color = 'transparent'
      src.crop_resized!( photo[:size].width, photo[:size].height )
      src.rotate!( photo[:rotate] ) unless photo[:rotate] == 0
      dst.composite!( src, photo[:offset].left, photo[:offset].top, Magick::OverCompositeOp )
    end
    
    PageLayout.caption( caption_text ).draw( dst ) if caption_text
    
    dst
  end
  
  def PageLayout.caption( text, gravity = Magick::SouthWestGravity )
    gc = Magick::Draw.new
    gc.gravity = gravity
    gc.pointsize = 24
    gc.font_family = "Chicago"
    gc.font_weight = Magick::BoldWeight
    gc.fill = 'white'
    gc.text( 0, 0, text )
    gc
  end
  
end

class ArtistAlbumPageBuilder
  PRINTS = {
    '2x3P'  => ImageSize.new( 240, 336 ),  # 2.5 x 3.5 - Portrait
    '2x3L'  => ImageSize.new( 336, 240 ),  # 2.5 x 3.5 - Landscape
    '3x5P'  => ImageSize.new( 336, 480 ),  # 3.5 x 5 - Portrait
    '3x5L'  => ImageSize.new( 480, 336 ),  # 3.5 x 5 - Landscape
    '4x6P'  => ImageSize.new( 384, 576 ),  # 4 x 6 - Portrait
    '4x6L'  => ImageSize.new( 576, 384 ),  # 4 x 6 - Landscape
    '5x7P'  => ImageSize.new( 480, 672 ),  # 5 x 7 - Portrait
    '5x7L'  => ImageSize.new( 672, 480 ),  # 5 x 7 - Landscape
    '5x10P' => ImageSize.new( 480, 960 ), # 5 x 10 - Portrait
    '8x10P' => ImageSize.new( 768, 960 )  # 8 x 10 - Portrait
  }
  
  LAYOUTS = [ '1-46-V', '1-57-V-B', '1-57-V-T', '1-57-V-RT', '1-57-H-B', '1-57-H-T', '1-510-V', '1-810-V', '2-46-1', '2-46-2', '2-57-2', '2-M-45', '2-M-47', '2-M-31', '2-M-33', '3-35-ST-H-L', '3-35-ST-H-R', '3-35-V-1', '3-35-V-3', '3-35-H-1', '3-35-H-3', '3-46-22', '3-M-81', '3-M-83', '4-46-1', '4-M-21', '4-M-23', '4-MM-1', '4-MM-3', '6-M-1', '6-M-3', '9-23-1' ]
  
  TEST_PAGES = {
      '1-46-V'      => [ '_sample_portrait.jpg' ], 
      '1-57-V-B'    => [ '_sample_portrait.jpg' ], 
      '1-57-V-T'    => [ '_sample_portrait.jpg' ], 
      '1-57-V-RT'   => [ '_sample_portrait.jpg' ], 
      '1-57-H-B'    => [ '_sample_landscape.jpg' ], 
      '1-57-H-T'    => [ '_sample_landscape.jpg' ], 
      '1-510-V'     => [ '_sample_portrait.jpg' ], 
      '1-810-V'     => [ '_sample_portrait.jpg' ], 
      '2-46-1'      => [ '_sample_portrait.jpg', '_sample_portrait.jpg' ], 
      '2-46-2'      => [ '_sample_landscape.jpg', '_sample_landscape.jpg' ], 
      '2-57-2'      => [ '_sample_landscape.jpg', '_sample_landscape.jpg' ], 
      '2-M-45'      => [ '_sample_portrait.jpg', '_sample_landscape.jpg' ], 
      '2-M-47'      => [ '_sample_landscape.jpg', '_sample_portrait.jpg' ], 
      '2-M-31'      => [ '_sample_portrait.jpg', '_sample_landscape.jpg' ], 
      '2-M-33'      => [ '_sample_landscape.jpg', '_sample_portrait.jpg' ], 
      '3-35-ST-H-L' => [ '_sample_landscape.jpg', '_sample_landscape.jpg', '_sample_landscape.jpg' ], 
      '3-35-ST-H-R' => [ '_sample_landscape.jpg', '_sample_landscape.jpg', '_sample_landscape.jpg' ], 
      '3-35-V-1'    => [ '_sample_portrait.jpg', '_sample_portrait.jpg', '_sample_portrait.jpg' ], 
      '3-35-V-3'    => [ '_sample_portrait.jpg', '_sample_portrait.jpg', '_sample_portrait.jpg' ], 
      '3-35-H-1'    => [ '_sample_landscape.jpg', '_sample_landscape.jpg', '_sample_landscape.jpg' ], 
      '3-35-H-3'    => [ '_sample_landscape.jpg', '_sample_landscape.jpg', '_sample_landscape.jpg' ], 
      '3-46-22'     => [ '_sample_landscape.jpg', '_sample_landscape.jpg', '_sample_landscape.jpg' ], 
      '3-M-81'      => [ '_sample_portrait.jpg', '_sample_portrait.jpg', '_sample_landscape.jpg' ], 
      '3-M-83'      => [ '_sample_landscape.jpg', '_sample_portrait.jpg', '_sample_portrait.jpg' ], 
      '4-46-1'      => [ '_sample_portrait.jpg', '_sample_portrait.jpg', '_sample_portrait.jpg', '_sample_portrait.jpg' ], 
      '4-M-21'      => [ '_sample_portrait.jpg', '_sample_portrait.jpg', '_sample_portrait.jpg', '_sample_portrait.jpg' ], 
      '4-M-23'      => [ '_sample_portrait.jpg', '_sample_portrait.jpg', '_sample_portrait.jpg', '_sample_portrait.jpg' ], 
      '4-MM-1'      => [ '_sample_landscape.jpg', '_sample_portrait.jpg', '_sample_landscape.jpg', '_sample_landscape.jpg' ], 
      '4-MM-3'      => [ '_sample_landscape.jpg', '_sample_landscape.jpg', '_sample_portrait.jpg', '_sample_landscape.jpg' ], 
      '6-M-1'       => [ '_sample_portrait.jpg', '_sample_landscape.jpg', '_sample_landscape.jpg', '_sample_portrait.jpg', '_sample_landscape.jpg', '_sample_portrait.jpg' ], 
      '6-M-3'       => [ '_sample_portrait.jpg', '_sample_landscape.jpg', '_sample_portrait.jpg', '_sample_landscape.jpg', '_sample_landscape.jpg', '_sample_portrait.jpg' ], 
      '9-23-1'      => [ '_sample_portrait.jpg', '_sample_portrait.jpg', '_sample_portrait.jpg', '_sample_portrait.jpg', '_sample_portrait.jpg', '_sample_portrait.jpg', '_sample_portrait.jpg', '_sample_portrait.jpg', '_sample_portrait.jpg' ]
  }
  
  def build_page( type, images )
    page = PageLayout.new( type )
    
    case type
      when '1-46-V'
        page.add_photo( images[0], PRINTS['4x6P'], offset = ImageOffset.new( 288, 432 ) )
      when '1-57-V-B'
        page.add_photo( images[0], PRINTS['5x7P'], offset = ImageOffset.new( 240, 576 ), 0, 'B' )
      when '1-57-V-T'
        page.add_photo( images[0], PRINTS['5x7P'], offset = ImageOffset.new( 240, 192 ), 0, 'A' )
      when '1-57-V-RT'
        page.add_photo( images[0], PRINTS['5x7P'], offset = ImageOffset.new( 161, 333 ), 15 )
      when '1-57-H-B'
        page.add_photo( images[0], PRINTS['5x7L'], offset = ImageOffset.new( 144, 736 ), 0, 'B' )
      when '1-57-H-T'
        page.add_photo( images[0], PRINTS['5x7L'], offset = ImageOffset.new( 144, 170 ), 0, 'A' )
      when '1-510-V'
        page.add_photo( images[0], PRINTS['5x10P'], offset = ImageOffset.new( 240, 235 ) )
      when '1-810-V'
        page.add_photo( images[0], PRINTS['8x10P'], offset = ImageOffset.new( 96, 235 ) )
      when '2-46-1'
        page.add_photo( images[0], PRINTS['4x6P'], offset = ImageOffset.new( 64, 432 ), 0, 'A' )
        page.add_photo( images[1], PRINTS['4x6P'], offset = ImageOffset.new( 512, 432 ), 0, 'B' )
      when '2-46-2'
        page.add_photo( images[0], PRINTS['4x6L'], offset = ImageOffset.new( 192, 268 ), 0, 'A' )
        page.add_photo( images[1], PRINTS['4x6L'], offset = ImageOffset.new( 192, 768 ), 0, 'B' )
      when '2-57-2'
        page.add_photo( images[0], PRINTS['5x7L'], offset = ImageOffset.new( 144, 160 ), 0, 'A' )
        page.add_photo( images[1], PRINTS['5x7L'], offset = ImageOffset.new( 144, 800 ), 0, 'B' )
      when '2-M-45'
        page.add_photo( images[0], PRINTS['3x5P'], offset = ImageOffset.new( 128, 185 ), 15, 'A' )
        page.add_photo( images[1], PRINTS['4x6L'], offset = ImageOffset.new( 202, 735 ), -15, 'B' )
      when '2-M-47'
        page.add_photo( images[0], PRINTS['4x6L'], offset = ImageOffset.new( 101, 185 ), -15, 'A' )
        page.add_photo( images[1], PRINTS['3x5P'], offset = ImageOffset.new( 384, 705 ), 15, 'B' )
      when '2-M-31'
        page.add_photo( images[0], PRINTS['4x6P'], offset = ImageOffset.new( 288, 128 ), 0, 'A' )
        page.add_photo( images[1], PRINTS['5x7L'], offset = ImageOffset.new( 144, 832 ), 0, 'B' )
      when '2-M-33'
        page.add_photo( images[0], PRINTS['5x7L'], offset = ImageOffset.new( 144, 128 ), 0, 'A' )
        page.add_photo( images[1], PRINTS['4x6P'], offset = ImageOffset.new( 288, 736 ), 0, 'B' )
      when '3-35-ST-H-L'
        page.add_photo( images[0], PRINTS['3x5L'], offset = ImageOffset.new( 96, 144 ), 0, 'A' )
        page.add_photo( images[1], PRINTS['3x5L'], offset = ImageOffset.new( 240, 552 ), 0, 'E' )
        page.add_photo( images[2], PRINTS['3x5L'], offset = ImageOffset.new( 384, 960 ), 0, 'D' )
      when '3-35-ST-H-R'
        page.add_photo( images[0], PRINTS['3x5L'], offset = ImageOffset.new( 384, 144 ), 0, 'B' )
        page.add_photo( images[1], PRINTS['3x5L'], offset = ImageOffset.new( 240, 552 ), 0, 'E' )
        page.add_photo( images[2], PRINTS['3x5L'], offset = ImageOffset.new( 96, 960 ), 0, 'C' )
      when '3-35-V-1'
        page.add_photo( images[0], PRINTS['3x5P'], offset = ImageOffset.new( 88, 85 ), 15, 'A' )
        page.add_photo( images[1], PRINTS['3x5P'], offset = ImageOffset.new( 536, 480 ), 0, 'BD' )
        page.add_photo( images[2], PRINTS['3x5P'], offset = ImageOffset.new( 88, 805 ), -15, 'C' )
      when '3-35-V-3'
        page.add_photo( images[0], PRINTS['3x5P'], offset = ImageOffset.new( 424, 85 ), -15, 'B' )
        page.add_photo( images[1], PRINTS['3x5P'], offset = ImageOffset.new( 88, 480 ), 0, 'AC' )
        page.add_photo( images[2], PRINTS['3x5P'], offset = ImageOffset.new( 424, 805 ), 15, 'D' )
      when '3-35-H-1'
        page.add_photo( images[0], PRINTS['3x5L'], offset = ImageOffset.new( 328, 104 ), 15, 'B' )
        page.add_photo( images[1], PRINTS['3x5L'], offset = ImageOffset.new( 96, 552 ), 0, 'E' )
        page.add_photo( images[2], PRINTS['3x5L'], offset = ImageOffset.new( 328, 888 ), -15, 'D' )
      when '3-35-H-3'
        page.add_photo( images[0], PRINTS['3x5L'], offset = ImageOffset.new( 82, 104 ), -15, 'A' )
        page.add_photo( images[1], PRINTS['3x5L'], offset = ImageOffset.new( 384, 552 ), 0, 'E' )
        page.add_photo( images[2], PRINTS['3x5L'], offset = ImageOffset.new( 82, 888 ), 15, 'C' )
      when '3-46-22'
        page.add_photo( images[0], PRINTS['4x6L'], offset = ImageOffset.new( 192, 72 ), 0, 'A' )
        page.add_photo( images[1], PRINTS['4x6L'], offset = ImageOffset.new( 192, 528 ), 0, 'B' )
        page.add_photo( images[2], PRINTS['4x6L'], offset = ImageOffset.new( 192, 984 ), 0, 'C' )
      when '3-M-81'
        page.add_photo( images[0], PRINTS['2x3P'], offset = ImageOffset.new( 161, 403 ), -15, 'A' )
        page.add_photo( images[1], PRINTS['2x3P'], offset = ImageOffset.new( 479, 210 ), 15, 'B' )
        page.add_photo( images[2], PRINTS['3x5L'], offset = ImageOffset.new( 240, 894 ), 0, 'CD' )
      when '3-M-83'
        page.add_photo( images[0], PRINTS['3x5L'], offset = ImageOffset.new( 240, 210 ), 0, 'AB' )
        page.add_photo( images[1], PRINTS['2x3P'], offset = ImageOffset.new( 161, 844 ), 15, 'C' )
        page.add_photo( images[2], PRINTS['2x3P'], offset = ImageOffset.new( 479, 701 ), -15, 'D' )
      when '4-46-1'
        page.add_photo( images[0], PRINTS['4x6P'], offset = ImageOffset.new( 64, 114 ), 0, 'A' )
        page.add_photo( images[1], PRINTS['4x6P'], offset = ImageOffset.new( 512, 114 ), 0, 'B' )
        page.add_photo( images[2], PRINTS['4x6P'], offset = ImageOffset.new( 64, 750 ), 0, 'C' )
        page.add_photo( images[3], PRINTS['4x6P'], offset = ImageOffset.new( 512, 750 ), 0, 'D' )
      when '4-M-21'
        page.add_photo( images[0], PRINTS['2x3P'],  offset = ImageOffset.new( 80, 108 ), 0, 'A' )
        page.add_photo( images[1], PRINTS['2x3P'],  offset = ImageOffset.new( 80, 552 ), 0, 'E' )
        page.add_photo( images[2], PRINTS['2x3P'],  offset = ImageOffset.new( 80, 996 ), 0, 'C' )
        page.add_photo( images[3], PRINTS['5x10P'], offset = ImageOffset.new( 400, 240 ), 0, 'BD' )
      when '4-M-23'
        page.add_photo( images[0], PRINTS['5x10P'], offset = ImageOffset.new( 80, 240 ), 0, 'AC' )
        page.add_photo( images[1], PRINTS['2x3P'],  offset = ImageOffset.new( 640, 108 ), 0, 'B' )
        page.add_photo( images[2], PRINTS['2x3P'],  offset = ImageOffset.new( 640, 552 ), 0, 'E' )
        page.add_photo( images[3], PRINTS['2x3P'],  offset = ImageOffset.new( 640, 996 ), 0, 'D' )
      when '4-MM-1'
        page.add_photo( images[0], PRINTS['5x7L'], offset = ImageOffset.new( 144, 96 ), 0, 'AB' )
        page.add_photo( images[1], PRINTS['3x5P'], offset = ImageOffset.new( 79, 768 ), 0, 'C' )
        page.add_photo( images[2], PRINTS['2x3L'], offset = ImageOffset.new( 494, 696 ), 15, 'E' )
        page.add_photo( images[3], PRINTS['2x3L'], offset = ImageOffset.new( 494, 1014 ), 15, 'D' )
      when '4-MM-3'
        page.add_photo( images[0], PRINTS['2x3L'], offset = ImageOffset.new( 79, 108 ), 15, 'A' )
        page.add_photo( images[1], PRINTS['2x3L'], offset = ImageOffset.new( 79, 426 ), 15, 'E' )
        page.add_photo( images[2], PRINTS['3x5P'], offset = ImageOffset.new( 554, 192 ), 0, 'B' )
        page.add_photo( images[3], PRINTS['5x7L'], offset = ImageOffset.new( 144, 864 ), 0, 'CD' )
      when '6-M-1'
        page.add_photo( images[0], PRINTS['3x5P'], offset = ImageOffset.new( 96, 96 ), 0, 'A' )
        page.add_photo( images[1], PRINTS['2x3L'], offset = ImageOffset.new( 528, 96 ), 0, 'B' )
        page.add_photo( images[2], PRINTS['2x3L'], offset = ImageOffset.new( 96, 672 ), 0, 'C' )
        page.add_photo( images[3], PRINTS['3x5P'], offset = ImageOffset.new( 528, 432 ), 0, 'D' )
        page.add_photo( images[4], PRINTS['3x5L'], offset = ImageOffset.new( 96, 1008 ), 0, 'E' )
        page.add_photo( images[5], PRINTS['2x3P'], offset = ImageOffset.new( 624, 1008 ), 0, 'F' )
      when '6-M-3'
        page.add_photo( images[0], PRINTS['2x3P'], offset = ImageOffset.new( 96, 96 ), 0, 'A' )
        page.add_photo( images[1], PRINTS['3x5L'], offset = ImageOffset.new( 384, 96 ), 0, 'B' )
        page.add_photo( images[2], PRINTS['3x5P'], offset = ImageOffset.new( 96, 528 ), 0, 'C' )
        page.add_photo( images[3], PRINTS['2x3L'], offset = ImageOffset.new( 528, 528 ), 0, 'D' )
        page.add_photo( images[4], PRINTS['2x3L'], offset = ImageOffset.new( 96, 1100 ), 0, 'E' )
        page.add_photo( images[5], PRINTS['3x5P'], offset = ImageOffset.new( 528, 864 ), 0, 'F' )
      when '9-23-1'
        page.add_photo( images[0], PRINTS['2x3P'], offset = ImageOffset.new( 60, 138 ), 0, 'A' )
        page.add_photo( images[1], PRINTS['2x3P'], offset = ImageOffset.new( 360, 138 ), 0, 'B' )
        page.add_photo( images[2], PRINTS['2x3P'], offset = ImageOffset.new( 660, 138 ), 0, 'C' )
        page.add_photo( images[3], PRINTS['2x3P'], offset = ImageOffset.new( 60, 552 ), 0, 'D' )
        page.add_photo( images[4], PRINTS['2x3P'], offset = ImageOffset.new( 360, 552 ), 0, 'E' )
        page.add_photo( images[5], PRINTS['2x3P'], offset = ImageOffset.new( 660, 552 ), 0, 'F' )
        page.add_photo( images[6], PRINTS['2x3P'], offset = ImageOffset.new( 60, 966 ), 0, 'G' )
        page.add_photo( images[7], PRINTS['2x3P'], offset = ImageOffset.new( 360, 966 ), 0, 'H' )
        page.add_photo( images[8], PRINTS['2x3P'], offset = ImageOffset.new( 660, 966 ), 0, 'I' )
    end
    
    page
  end
  
  def samples
    unless FileTest::exists? '_sample_portrait.jpg'
      portrait = Magick::Image.new( 240, 336 ) { self.background_color = '#AAAAAA' }
      PageLayout.caption( "Portrait", Magick::CenterGravity ).draw( portrait )
      portrait.write( '_sample_portrait.jpg' )
    end
    
    unless FileTest::exists? '_sample_landscape.jpg'
      landscape = Magick::Image.new( 336, 240 ) { self.background_color = '#AAAAAA' }
      PageLayout.caption( "Landscape", Magick::CenterGravity ).draw( landscape )
      landscape.write( '_sample_landscape.jpg' )
    end
    
    TEST_PAGES.each do |type, photos|
      page = build_page( type, photos )
      image = page.create( type )
      image.write( type + '.jpg' )
    end
  end
  
  def valid_layout?( layout )
    LAYOUTS.include?( layout )
  end

end

def show_usage
  puts "Usage: ruby album_page.rb layout_type filename [filename..]"
  puts "  where filename is a list of the photos for the layout."
  puts ""
  puts "To build sample files: ruby album_page.rb --samples"
  puts ""
  exit 1
end

album = ArtistAlbumPageBuilder.new
layout = ARGV.shift.upcase rescue show_usage

if '--samples' == layout.downcase
  album.samples
  puts "Samples built."
  puts ""
  exit 1
end

unless album.valid_layout? layout
  puts "Invalid layout type."
  puts ""
  show_usage
end

unless layout[0,1].to_i == ARGV.size
  puts "Incorrect number of filenames for given layout."
  puts ""
  show_usage
end

page = album.build_page( layout, ARGV )
image = page.create( page.to_s )
image.write( 'temp.jpg' )

puts ""
puts "Created File: 'temp.jpg'"
puts "#{page.to_s}"
puts ""
