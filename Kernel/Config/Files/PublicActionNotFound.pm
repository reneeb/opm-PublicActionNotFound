package Kernel::Config::Files::PublicActionNotFound;

use strict;
use warnings;

use Kernel::System::Web::InterfacePublic;
use Kernel::Language qw(Translatable);

our $ObjectManagerDisabled = 1;

my $Loaded;

if ( !$Loaded ) {
    no warnings 'redefine';

    my $OrigPublic = *Kernel::System::Web::InterfacePublic::Run{CODE};

    *Kernel::System::Web::InterfacePublic::Run = \&_CheckPublicAction;

    sub _CheckPublicAction {
        my ($Self, %Param) = @_;

        my $Action = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam(
            Param => 'Action',
        );

        if ( $Action ) {
            my $ActionLoaded = $Kernel::OM->Get('Kernel::System::Main')->Require(
                "Kernel::Modules::$Action",
                Silent => 1,
            );

            if ( !$ActionLoaded ) {
                my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

                my $Output = $LayoutObject->CustomerHeader(
                    Area  => 'Frontend',
                    Title => 'Fatal Error'
                );

                $Output .= $LayoutObject->Output(
                    TemplateFile => 'CustomerError',
                    Data         => {
                        BackendTraceback => 'Page Not Found',
                        BackendMessage   => 'Page Not Found',
                        Message          => 'Page Not Found',
                    }
                );

                $Output .= $LayoutObject->CustomerFooter();
                $LayoutObject->Print( Output => \$Output );

                return 1;
            }
        }

        return $Self->$OrigPublic(%Param);
    };

    $Loaded++;
}

sub Load {}

1;
